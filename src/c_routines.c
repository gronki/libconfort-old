
/**************** C O N F O R T ****************/
/*  (c) 2017 Dominik Gronkiewicz <gronki@gmail.com>
    Distributed under MIT License.

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

************************************************/


#include <confort.h>


/*** mincf_read ***
 * @param cfg      Reference to confort structure
 * @param fn       Filename. If NULL, stdin will be used.
 * @returns         Success (zero) or error (nonzero)
 */
int mincf_read(confort *cfg, char *fn) {
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
        memset(cfg,0,sizeof(confort));
        errno = (MINCF_ERROR | MINCF_FILE_NOT_FOUND);
    }
    return errno;
}



/*** mincf_get ***
 * @param cfg       Reference to confort structure
 * @param key       Key to be searched for (cannot be NULL)
 * @param buf       Pointer to destination buffer
 * @param sz        Buffer size
 * @param defvalue  Default value if entry is not found
 *                  if NULL, error value will be returned
 *                  error value will be returned.
 * @returns         Success (zero) or error (nonzero)
 */
int mincf_get(confort *cfg, char *key,
        char *buf, size_t sz,
        char *defvalue) {
    mincf_rec *rec;

    if (!key || !cfg)  return (MINCF_ERROR | MINCF_ARGUMENT_ERROR);

    rec = mincf_record_query(cfg,key);

    if ( rec ) {
        if (buf) {
            // select shorter length (value or buffer) for copying
            mincf_export_rec(cfg,rec,buf,sz);
        }
        return MINCF_OK;
    } else {
        // if no key was found but default value was given, use it
        if (buf && defvalue) {
            strncpy(buf,defvalue,sz);
            return MINCF_OK;
        }
        // nothing found and no default
        return MINCF_NOT_FOUND;
    }

}

int mincf_exists(confort *cfg, char *key) {
    if (!key || !cfg)  return (MINCF_ERROR | MINCF_ARGUMENT_ERROR);

    return mincf_record_query(cfg,key)
        ? MINCF_OK
        : (MINCF_OK | MINCF_NOT_FOUND);
}
