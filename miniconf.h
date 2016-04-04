
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
const size_t mincf_bufsz = 2048;

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
int mincf_get_req(miniconf* conf, char* key, char* buf, size_t sz);
int mincf_get_def(miniconf* conf, char* key, char* defvalue, char* buf, size_t sz);
void mincf_free(miniconf* conf);

/* FORTRAN BINDINGS */
int mincf_read_(miniconf**);
int mincf_readf_(miniconf**, char *fn, size_t fn_sz);
int mincf_get_0_(miniconf* conf, char* key, char* buf, size_t key_sz, size_t buf_sz);
int mincf_get_req_(miniconf* conf, char* key, char* buf, size_t key_sz, size_t buf_sz);
void mincf_free_(miniconf* conf);

void * strcpy_f2c(char* dest, size_t dest_sz, char* src, size_t src_sz);
void * strcpy_c2f(char* dest, size_t dest_sz, char* src);
void * strcpy_f2f(char* dest, size_t dest_sz, char* src, size_t src_sz);

#endif
