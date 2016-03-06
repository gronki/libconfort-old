
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
    01/02/16 Added mincf_get_rq.
************************************************/


#include "miniconf.h"

miniconf* mincf_read(FILE* in) {

    char ch;
    int state = PST_B4LABEL;
    int pos = -1;
    int comment = 0;
    int hold = 0;
    int exitloop = 0;
    int t,i;
    char* tmp;

    miniconf* conf;
    mincf_rec *rec, *tmprec;

    const char s_whsp[] = " \t\n";
    const char s_alph[] = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
    const char s_lbls[] = "0123456789qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM.:-_/";
    const char s_nums[] = "0123456789";

    char none_synonyms[3][20];
    strcpy(none_synonyms[0],"empty");
    strcpy(none_synonyms[1],"None");
    strcpy(none_synonyms[2],"NULL");


    // alloc the structure
    conf = (miniconf*) malloc(sizeof(miniconf));
    if (!conf) return NULL;
    memset(conf, 0, sizeof(miniconf));

    // create buffer
    conf -> buffer_sz = 1024;
    conf -> buffer = (char*) malloc(conf -> buffer_sz);
    if (!conf -> buffer) {
        mincf_free(conf);
        return NULL;
    }
    memset(conf->buffer, 0, conf->buffer_sz);

    // create memory for records and zero it
    conf -> records_sz = 128;
    conf -> records = (mincf_rec*) malloc(conf -> records_sz * sizeof(mincf_rec));
    if (!conf -> records) {
        mincf_free(conf);
        return NULL;
    }
    memset(conf->records, 0, conf -> records_sz * sizeof(mincf_rec));

    // iterate thru characters
    while(!exitloop) {
        // running out of space?
        if ( conf->n_records >= conf->records_sz ) {
            tmprec = (mincf_rec*) realloc(conf->records,
                conf -> records_sz * sizeof(mincf_rec) * 2);
            if (!tmprec) {
                printf("error: not enough memory.\n");
                mincf_free(conf);
                return NULL;
            }
            conf->records = tmprec;
            conf -> records_sz = conf -> records_sz * 2;
        }
// printf("'%c', s:%d, h:%d, c:%d, r:%d\n", ch, state, hold, comment, conf->n_records);
        // take the current record
        rec = &(conf->records[conf->n_records]);

        // if not hold character, take new one from input
        if (!hold) {
            ch = fgetc(in);
            // if eof, set as zero and run last iteration
            if (ch == EOF) {
                exitloop = 1;
                ch = '\0';
            }
            pos++;
            if ( pos+1 >= conf->buffer_sz ) {
                tmp = (char*)realloc(conf->buffer,
                        conf->buffer_sz*2);
                if (!tmp) {
                    printf("error: not enough memory.\n");
                    mincf_free(conf); return NULL;
                }
                conf->buffer = tmp;
                conf->buffer_sz = conf->buffer_sz*2;
            }
            (conf->buffer)[pos] = ch;
        } else {
            // hold char. do nothing. just disable hold
            hold = 0;
        }

        // if comment is on, ignore until the end of the comment
        // terminating character is passed
        if (comment) {
            if (ch == '\n' || ch == '\0') {
                comment = 0;
            } else {
                continue;
            }
        }

        // ignore whitespaces sometimes
        if (state == PST_B4LABEL || state == PST_B4VALUE || state == PST_AFVALUE) {
            if (strchr(s_whsp,ch) != NULL) {
                continue;
            }
        }

        // check the parser state
        switch (state) {
            case PST_B4LABEL:
                // comment?
                if (ch == '#') {
                    comment = 1; hold = 1; break;
                }
                //  alphanumeric -> this is new label
                if ( strchr(s_alph,ch) != NULL ) {
                    state = PST_INLABEL;
                    rec -> k0 = pos;
                    hold = 1; break;
                }
                printf("config syntax error: unexpected character '%c'\n",ch);
                mincf_free(conf); return NULL;
                break;
            case PST_INLABEL:
                // exit the label
                if ( strchr(s_lbls,ch) == NULL ) {
                    //  save length
                    rec->kn = pos - rec->k0;
                    hold = 1; state = PST_B4VALUE;
                }
                break;
            case PST_B4VALUE:
                if ( ch == '"' ) {
                    // its gonna be a quote
                    rec -> v0 = pos+1;
                    state = PST_INQUOTE;
                } else if (ch == '\0' || ch == '\n') {
                    printf("config syntax error: expected value after label\n");
                    mincf_free(conf); return NULL;
                } else {
                    rec -> v0 = pos;
                    state = PST_INVALUE;
                    hold = 1;
                }
                break;
            case PST_INVALUE:
                switch (ch) {
                    case '#':
                        comment = 1; hold = 1;
                    case '\0':
                    case '\n':
                        // go to after value state
                        state = PST_AFVALUE;
                        // calculate the length
                        rec->vn = pos - rec->v0;
                        // iterate backwards to check for whitespaces. when the loop
                        // ends, i is the index of last non-whitespace character. then
                        // we can derive proper length. if the length was ok to start with
                        // the loop will end after first iteration and rec->vn wil remain
                        // unchanged.
                        for (i = pos-1; i >= rec->v0; i--) {
                            if ( strchr(s_whsp,(conf->buffer)[i]) == NULL )
                                break;
                        }
                        rec->vn = (i+1) - rec->v0;
// printf("append! n:%d, l:%d\n",conf->n_records,rec->vn);
                        conf->n_records++;
                }
                if (ch == '#') state = PST_B4LABEL;
                break;
            case PST_AFVALUE:
                if ( strchr(s_nums,ch) != NULL ) {
                    // we allow numerical lists to be continued
                    state = PST_INVALUE;
// printf("retract... n:%d, l:%d\n",conf->n_records,rec->vn);
                    conf->n_records--;
                } else {
                    state = PST_B4LABEL;
                }
                hold = 1;
                break;
            case PST_INQUOTE:
                if (ch == '"' || ch == '\0') {
                    state = PST_B4LABEL;
                    rec->vn = pos - rec->v0;
// printf("append! n:%d, l:%d\n",conf->n_records,rec->vn);
                    rec++; conf->n_records++;
                }
                break;
        }

    }

    // conf->longest_val = 0;
    // rec = &(conf->records[0]);
    // for ( i = 0; i < (conf->n_records - 1); i++,rec++ ) {
    //     if ( rec->vn > conf->longest_val ) {
    //         conf->longest_val = rec->vn;
    //     }
    // }

                    // printf("%s: %d: \n",__FILE__,__LINE__);

    return conf;
}



int mincf_get(miniconf* conf, char* key, char* buf, size_t sz) {
    int key_sz,i,n;
    mincf_rec* rec;

    key_sz = strlen(key);
    buf[0] = 0;

    for ( i = conf->n_records-1; i >= 0; i-- ) {
        rec = &(conf->records[i]);
        if ( rec->kn != key_sz ) continue;
        if (!strncmp( &(conf->buffer[rec->k0]), key, key_sz )) {
            n = (rec->vn < sz-1) ? rec->vn : sz-1;
            memset(buf,0,sz);
            strncpy(buf, &(conf->buffer[rec->v0]), n);
            return rec->vn;
        }
    }
    return MINCF_NOT_FOUND;
}

int mincf_getf(miniconf* conf, char* key, void* dest, MINCF_TYPE type) {
    char buf[128];
    int r;

    r = mincf_get(conf,key,buf,128);
    if ( r != MINCF_NOT_FOUND ) {
        switch (type) {
            case MINCF_INT:
                sscanf(buf,"%d",dest);
                return r;
            case MINCF_FLOAT:
                sscanf(buf,"%f",dest);
                return r;
            case MINCF_DOUBLE:
                sscanf(buf,"%lf",dest);
                return r;
        }
    }
    return MINCF_NOT_FOUND;
}

int mincf_get_rq(miniconf* conf, char* key, char* buf, size_t sz) {
    int r;

    r = mincf_get(conf,key,buf,sz);
    if ( r == MINCF_NOT_FOUND ) {
        fprintf(stderr, "miniconf: entry '%s' undefined.\n",key);
        mincf_free(conf);
    }
    return r;
}

void mincf_free(miniconf* conf) {
    if ( conf -> buffer != NULL ) {
        free(conf->buffer);
    }
    if ( conf -> records != NULL ) {
        free(conf->records);
    }
    if (conf)    free(conf);
}


/* FORTRAN BINDINGS */
miniconf* mincf_read_() {
    return mincf_read(stdin);
}

char* mincf_stralloc(char* s, size_t n) {
    char* buf;
    buf = (char*)malloc(n+1);
    strncpy(buf,s,n); buf[n] = 0;
    return buf;
}

miniconf* mincf_readf_(char *fn, size_t fn_sz) {
    char fn2[1024];
    miniconf* ret = NULL;
    FILE* f;

    if ( fn_sz > 1023 ) {
        fprintf(stderr,"miniconf: filename too long. (>1023)\n");
        return NULL;
    }

    memset(fn2, 0, 1024);
    memcpy(fn2, fn, fn_sz);

    if ( (f=fopen(fn2,"r")) != NULL ) {
        ret = mincf_read(f);
        fclose(f);
    }
    return ret;
}

int mincf_get_(miniconf* conf, char* key, char* buf, size_t key_sz, size_t buf_sz) {
    char key2[1024];
    int ret;
    size_t val_sz;

    if ( key_sz > 1023 ) {
        fprintf(stderr,"miniconf: key too long. (>1023)\n");
        return MINCF_NOT_FOUND;
    }

    // printf("%s:%d:'%s',%d,%d,%d,%12.4e\n",__FILE__,__LINE__,key2,key_sz,buf_sz,conf->n_records,1.21e-5);

    memset(key2,0,1024);
    memcpy(key2,key,key_sz);

    memset(buf,0,buf_sz);
    ret = mincf_get(conf,key2,buf,buf_sz);
    val_sz = strlen(buf);
    memset(buf + val_sz, ' ', buf_sz - val_sz );

    return ret;
}

int mincf_get_rq_(miniconf* conf, char* key, char* buf, size_t key_sz, size_t buf_sz) {
    int r; char key2[1024];

    r = mincf_get_(conf,key,buf,key_sz,buf_sz);
    if ( r == MINCF_NOT_FOUND ) {
        memset(key2,0,1024);
        strncpy(key2,key, (key_sz<1023 ? key_sz : 1023) );
        fprintf(stderr, "miniconf: entry '%s' undefined.\n",key2);
        mincf_free(conf);
    }
    return r;
}

void mincf_free_(miniconf* conf) {
    mincf_free(conf);
}
