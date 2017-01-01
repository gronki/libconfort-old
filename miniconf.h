
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

#define MINCF_OK                   (0)
#define MINCF_ERROR                (1)
#define MINCF_ARGUMENT_ERROR    (1<<1)
#define MINCF_MEMORY_ERROR      (1<<2)
#define MINCF_FILE_NOT_FOUND    (1<<3)
#define MINCF_SYNTAX_ERROR      (1<<4)
#define MINCF_NOT_FOUND         (1<<5)

typedef struct {
    int k0; int kn;
    int v0; int vn;
    int flag;
} mincf_rec;

typedef struct {
    char* buffer;
    size_t buffer_sz;
    size_t n_records;
    size_t records_sz;
    mincf_rec* records;
} miniconf;

// core functions
int mincf_parse_stream(miniconf *cfg, FILE *in);
mincf_rec* mincf_record_query(miniconf *cfg, char *key);
char *mincf_export_rec(miniconf *cfg, mincf_rec *rec, char *buf, size_t sz);
void mincf_free(miniconf *cfg);

// C interface
int mincf_read(miniconf *cfg, char *fn);
int mincf_get(miniconf *cfg, char *key, char *buf, size_t sz, char *defvalue);

// Fortran interface
void cstr_fix(char *buf, size_t sz);
char *cstr_alloc(char *buf, size_t sz);
void fort_mincf_read_stdin(miniconf *cfg, int *errno);
void fort_mincf_read_file(miniconf *cfg, char *fn_str, size_t fn_sz, int *errno);
void fort_mincf_get_default(miniconf *cfg,
        char *key_str, size_t key_sz,
        char *buf, size_t sz,
        char *defvalue_str, size_t defvalue_sz,
        int* errno);
void fort_mincf_get(miniconf *cfg,
            char *key_str, size_t key_sz,
            char *buf, size_t sz,
            int* errno);
void fort_mincf_get_exists(miniconf *cfg,
            char *key_str, size_t key_sz,
            int* errno);
#endif
