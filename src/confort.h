
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


#ifndef __confort__
#define __confort__

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
} confort;

// core functions
int mincf_parse_stream(confort *cfg, FILE *in);
mincf_rec* mincf_record_query(confort *cfg, char *key);
char *mincf_export_rec(confort *cfg, mincf_rec *rec, char *buf, size_t sz);
void mincf_free(confort *cfg);

// C interface
int mincf_read(confort *cfg, char *fn);
int mincf_get(confort *cfg, char *key, char *buf, size_t sz, char *defvalue);
int mincf_exists(confort *cfg, char *key);

// Fortran interface
void cstr_fix(char *buf, size_t sz);
char *cstr_alloc(char *buf, size_t sz);
void fort_mincf_read_stdin(confort *cfg, int *errno);
void fort_mincf_read_file(confort *cfg, char *fn_str, size_t fn_sz, int *errno);
void fort_mincf_get_default(confort *cfg,
        char *key_str, size_t key_sz,
        char *buf, size_t sz,
        char *defvalue_str, size_t defvalue_sz,
        int* errno);
void fort_mincf_get(confort *cfg,
            char *key_str, size_t key_sz,
            char *buf, size_t sz,
            int* errno);
void fort_mincf_get_exists(confort *cfg,
            char *key_str, size_t key_sz,
            int* errno);
#endif
