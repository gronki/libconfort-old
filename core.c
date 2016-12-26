
/*************** M I N I C O N F ***************/
/*  This small library allows to read a simple
    configuration file. Data can be read from
    any FILE* handle (for example stdin).
    Dominik Gronkiewicz 2016  gronki@gmail.com
    GNU GPL 2 license.

    Example file:
    --------------------------
    key1 value1

    # comment
    key2 value2 value3   #  another comment

    key3 "very long # text
    with newline"

    key4   5.0
    key5   6.0  7.5  # hoorayy it's the end
    --------------------------
    CHANGELOG:
    25/02/16 get now searches backwards so that the last
        duplicated entry is found
    01/02/16 Added mincf_get_req.
************************************************/


#include "miniconf.h"


void cstr_fix(char* buf, size_t sz);

/*** mincf_read ***
 * @param cfg      Reference to miniconf structure
 * @param fn       Filename. If NULL, stdin will be used.
 * @returns         Success (zero) or error (nonzero)
 */
int mincf_read(miniconf *cfg, char *fn) {
    FILE *f;
    int errno = MINCF_OK;

    if ( fn ) {
        f = fopen(fn,"r");
    } else {
        f = stdin;
    }

    if ( f ) {
        errno = mincf_parse_stream(cfg,f);
        fclose(f);
    } else {
        errno = (MINCF_ERROR | MINCF_FILE_NOT_FOUND);
    }
    return errno;
}


/*** mincf_get ***
 * @param cfg       Reference to miniconf structure
 * @param key       Key to be searched for (cannot be NULL)
 * @param buf       Pointer to destination buffer
 * @param sz        Buffer size
 * @param defvalue  Default value if entry is not found
 *                  if NULL, error value will be returned
 *                  error value will be returned.
 * @returns         Success (zero) or error (nonzero)
 */
int mincf_get(miniconf *cfg, char *key,
        char *buf, size_t sz,
        char *defvalue) {
    int key_sz,i,n;
    mincf_rec *rec;

    if (!key || !cfg)  return (MINCF_ERROR | MINCF_ARGUMENT_ERROR);

    key_sz = strlen(key);

    // go from last to first, so that last defined record with the same name
    // is significant
    for ( i = cfg->n_records-1; i >= 0; i-- ) {
        rec = &(cfg->records[i]);
        // if length doesn't match, early continue
        if ( rec->kn != key_sz ) continue;
        // compare the keys
        if (!strncmp( &(cfg->buffer[rec->k0]), key, key_sz )) {
            // if no buffer is provided, just check for key existence
            if (buf) {
                // select shorter length (value or buffer) for copying
                n = (rec->vn < sz-1) ? rec->vn : sz-1;
                strncpy(buf, &(cfg->buffer[rec->v0]), n);
            }
            return MINCF_OK;
        }
    }
    // if no key was found but default value was given, use it
    if (buf && defvalue) {
        strncpy(buf,defvalue,sz);
        return MINCF_OK;
    }
    // nothing found and no default
    return MINCF_NOT_FOUND;
}

/* fortran binding */
void fort_mincf_read_stdin(miniconf *cfg, int *errno) {
    *errno = mincf_read(cfg,NULL);
}
void fort_mincf_read_file(miniconf *cfg, char *fn, int *errno) {
    *errno = mincf_read(cfg,fn);
}
void fort_mincf_get(miniconf *cfg, char *key, char *buf, size_t sz, int* errno) {
    *errno = mincf_get(cfg,key,buf,sz,NULL);
    if ( *errno == 0 ) cstr_fix(buf,sz);
}
void fort_mincf_get_default(miniconf *cfg, char *key, char *buf, size_t sz, char *defvalue, int* errno) {
    *errno = mincf_get(cfg,key,buf,sz,defvalue);
    if ( *errno == 0 ) cstr_fix(buf,sz);
}

// This converts C string to Fortran whitespace-filled string
void cstr_fix(char* buf, size_t sz) {
    size_t i;
    register int dup = 0;
    for (i = 0; i < sz; i++) {
        dup = dup || (buf[i] < 0x20);
        if ( dup ) buf[i] = ' ';
    }
}

/*** mincf_free ***
 * @param cfg       Reference to miniconf structure
 */
void mincf_free(miniconf *cfg) {
    if ( !cfg ) return;
    if ( cfg -> buffer != NULL ) {
        free(cfg -> buffer);
        cfg -> buffer = NULL;
    }
    if ( cfg -> records != NULL ) {
        free(cfg -> records);
        cfg -> records = NULL;
    }
}
