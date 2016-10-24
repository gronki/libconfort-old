
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



extern const int MINCF_OK;
extern const int MINCF_ERROR;
extern const int MINCF_ARGUMENT_ERROR;
extern const int MINCF_MEMORY_ERROR;
extern const int MINCF_FILE_NOT_FOUND;
extern const int MINCF_SYNTAX_ERROR;
extern const int MINCF_NOT_FOUND;



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


int mincf_parse_stream(miniconf *cfg, FILE *in);
int mincf_read(miniconf *cfg, char *fn);
int mincf_get(miniconf *cfg, char *key, char *buf, size_t sz, char *defvalue);
void mincf_free(miniconf *cfg);

void fort_mincf_read(miniconf *cfg, char *fn, int *error);

#endif
