#include "miniconf.h"

void cstr_fix(char* buf, size_t sz);

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
