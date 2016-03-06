
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
************************************************/

#ifndef __MINICONF__
#define __MINICONF__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#define PST_B4LABEL 0
#define PST_INLABEL 1
#define PST_B4VALUE 2
#define PST_INVALUE 3
#define PST_AFVALUE 4
#define PST_INQUOTE 5
#define MINCF_NOT_FOUND -1
typedef int MINCF_TYPE;
#define MINCF_INT 1
#define MINCF_FLOAT 2
#define MINCF_DOUBLE 3
#define MINCF_FLOAT64 3

typedef struct {
    int k0; int kn;
    int v0; int vn;
} mincf_rec;

typedef struct {
    char* buffer;
    size_t buffer_sz;
    unsigned int n_records;
    size_t records_sz;
    // size_t longest_val;
    mincf_rec* records;
} miniconf;

/**
 * Reads configuration from given file and allocates memory for data structure.
 */
miniconf* mincf_read(FILE* f);
int mincf_get(miniconf* conf, char* key, char* buf, size_t sz);
int mincf_getf(miniconf* conf, char* key, void* dest, MINCF_TYPE type);
int mincf_get_rq(miniconf* conf, char* key, char* buf, size_t sz);
void mincf_free(miniconf* conf);

char* mincf_stralloc(char* s, size_t n);

/* FORTRAN BINDINGS */
miniconf* mincf_read_();
miniconf* mincf_readf_(char *fn, size_t fn_sz);
int mincf_get_(miniconf* conf, char* key, char* buf, size_t key_sz, size_t buf_sz);
int mincf_get_rq_(miniconf* conf, char* key, char* buf, size_t key_sz, size_t buf_sz);
void mincf_free_(miniconf* conf);


#endif
