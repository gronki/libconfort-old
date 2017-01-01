
/*************** M I N I C O N F ***************/
/*  This small library allows to read a simple
    configuration file. Data can be read from
    any FILE* handle (for example stdin).
    Dominik Gronkiewicz 2016  gronki@gmail.com
    MIT license.

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


#include "miniconf.h"

// This converts C string to Fortran whitespace-filled string
void cstr_fix(char *buf, size_t sz) {
    size_t i;
    register int dup = 0;
    for (i = 0; i < sz; i++) {
        dup = dup || (buf[i] < 0x20);
        if ( dup ) buf[i] = ' ';
    }
}


char *cstr_alloc(char *buf, size_t sz) {

    char *bufc;

    size_t i,istart = 0, nbuf = 0;
    int truechar = 0;

    for ( i = 0; i < sz; ++i) {
        if ( buf[i] != 0x20 ) {
            if ( !truechar ) {
                truechar = 1;
                istart = i;
            }
            nbuf = i - istart + 1;
        }
    }

    bufc = (char*) malloc ( nbuf + 1 );
    if (!bufc) return NULL;
    memcpy( bufc, buf + istart, nbuf );
    bufc[nbuf] = 0;

    return bufc;
}


/* fortran binding */
void fort_mincf_read_stdin(miniconf *cfg, int *errno) {
    *errno = mincf_parse_stream(cfg,stdin);
}

void fort_mincf_read_file(miniconf *cfg, char *fn_str, size_t fn_sz, int *errno) {
    FILE* f;
    char *fn = cstr_alloc(fn_str,fn_sz);

    f = fopen(fn,"r");

    if (f) {
        *errno = mincf_parse_stream(cfg,f);
        fclose(f);
    } else {
        *errno = (MINCF_ERROR | MINCF_FILE_NOT_FOUND);
    }
    free(fn);
}

void fort_mincf_get(miniconf *cfg,
            char *key_str, size_t key_sz,
            char *buf, size_t sz,
            int* errno) {
    mincf_rec *rec;
    char *key = cstr_alloc(key_str,key_sz);

    rec = mincf_record_query(cfg,key);

    if ( rec ) {
        if (buf) {
            mincf_export_rec(cfg,rec,buf,sz);
            cstr_fix(buf,sz);
            *errno = MINCF_OK;
        } else {
            *errno = (MINCF_ERROR | MINCF_ARGUMENT_ERROR);
        }
    } else {
        *errno = (MINCF_ERROR | MINCF_NOT_FOUND);
    }

    free(key);
}

void fort_mincf_get_exists(miniconf *cfg,
            char *key_str, size_t key_sz,
            int* errno) {
    mincf_rec *rec;
    char *key = cstr_alloc(key_str,key_sz);

    rec = mincf_record_query(cfg,key);

    if ( rec ) {
        *errno = MINCF_OK;
    } else {
        *errno = (MINCF_ERROR | MINCF_NOT_FOUND);
    }

    free(key);
}

void fort_mincf_get_default(miniconf *cfg,
        char *key_str, size_t key_sz,
        char *buf, size_t sz,
        char *defvalue_str, size_t defvalue_sz,
        int* errno) {

    fort_mincf_get(cfg,key_str,key_sz,buf,sz,errno);
    if ( *errno != MINCF_OK ) {
        memset(buf,0x20,sz);
        memcpy(buf,defvalue_str, (sz < defvalue_sz) ? sz : defvalue_sz );
        *errno = MINCF_OK;
    }

}
