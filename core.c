
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

int mincf_parse_stream(miniconf *cfg, FILE *in) {

    char ch;
    int state = PST_B4LABEL;
    int pos = -1;
    int comment = 0;
    int hold = 0;
    int exitloop = 0;
    int skipwhites = 1;
    int i;
    char *tmp;

    mincf_rec *rec, *tmprec;

    const char s_whsp[] = " \t\n";
    const char s_alph[] = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
    const char s_lbls[] = "0123456789qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM.:-_/";
    const char s_nums[] = "0123456789";

    // char none_synonyms[3][8];
    // strcpy(none_synonyms[0],"empty");
    // strcpy(none_synonyms[1],"None");
    // strcpy(none_synonyms[2],"NULL");
    //
    // char flag_negation[] = "no";


    // zero the structure
    if (!cfg)  return (MINCF_ERROR | MINCF_ARGUMENT_ERROR);
    memset(cfg, 0, sizeof(miniconf));

    // if file handle is null, exit
    if (!in)  return (MINCF_ERROR | MINCF_ARGUMENT_ERROR);

    // create buffer
    cfg -> buffer_sz = 2048;
    cfg -> buffer = (char*) malloc(cfg -> buffer_sz);
    if (!cfg -> buffer) {
        return (MINCF_ERROR | MINCF_MEMORY_ERROR);
    }
    memset(cfg->buffer, 0, cfg->buffer_sz);

    // create memory for records and zero it
    cfg -> records_sz = 128;
    cfg -> records = (mincf_rec*) malloc(cfg -> records_sz * sizeof(mincf_rec));
    if (!cfg -> records) {
        mincf_free(cfg);
        return (MINCF_ERROR | MINCF_MEMORY_ERROR);
    }
    memset(cfg->records, 0, cfg -> records_sz * sizeof(mincf_rec));

    // iterate thru characters
    while(!exitloop) {
        // running out of space?
        if ( cfg->n_records >= cfg->records_sz ) {
            tmprec = (mincf_rec*) realloc(cfg->records,
                cfg -> records_sz * sizeof(mincf_rec) * 2);
            if (!tmprec) {
                perror("miniconf: not enough memory");
                mincf_free(cfg);
                return (MINCF_ERROR | MINCF_MEMORY_ERROR);
            }
            cfg->records = tmprec;
            cfg -> records_sz = cfg -> records_sz * 2;
        }
        // take the current record
        rec = &(cfg->records[cfg->n_records]);

        // if not hold character, take new one from input
        if (!hold) {
            ch = fgetc(in);
            // if eof, set as zero and run last iteration
            if (ch == EOF) {
                exitloop = 1;
                ch = '\0';
            }
            pos++;
            if ( pos+1 >= cfg->buffer_sz ) {
                tmp = (char*)realloc(cfg->buffer,
                        cfg->buffer_sz*2);
                if (!tmp) {
                    perror("miniconf: not enough memory");
                    mincf_free(cfg);
                    return (MINCF_ERROR | MINCF_MEMORY_ERROR);
                }
                cfg->buffer = tmp;
                cfg->buffer_sz = cfg->buffer_sz*2;
            }
            (cfg->buffer)[pos] = ch;
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
        skipwhites = (state == PST_B4LABEL || state == PST_B4VALUE || state == PST_AFVALUE);
        if (skipwhites) {
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
                fprintf(stderr,"config syntax error: unexpected character '%c'\n",ch);
                mincf_free(cfg);
                return (MINCF_ERROR | MINCF_SYNTAX_ERROR);
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
                    perror("config syntax error: expected value after label\n");
                    mincf_free(cfg);
                    return (MINCF_ERROR | MINCF_SYNTAX_ERROR);
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
                            if ( strchr(s_whsp,(cfg->buffer)[i]) == NULL )
                                break;
                        }
                        rec->vn = (i+1) - rec->v0;
                        cfg->n_records++;
                }
                if (ch == '#') state = PST_B4LABEL;
                break;
            case PST_AFVALUE:
                if ( strchr(s_nums,ch) != NULL ) {
                    // we allow numerical lists to be continued
                    state = PST_INVALUE;
                    cfg->n_records--;
                } else {
                    state = PST_B4LABEL;
                }
                hold = 1;
                break;
            case PST_INQUOTE:
                if (ch == '"' || ch == '\0') {
                    state = PST_B4LABEL;
                    rec->vn = pos - rec->v0;
                    rec++; cfg->n_records++;
                }
                break;
        }

    }


    return MINCF_OK;
}


mincf_rec* mincf_record_query(miniconf *cfg, char *key) {
    int key_sz,i;
    mincf_rec *rec;

    if (!key || !cfg)  return NULL;

    key_sz = strlen(key);

    // go from last to first, so that last defined record with the same name
    // is significant
    for ( i = cfg->n_records-1; i >= 0; --i ) {
        rec = &(cfg->records[i]);
        // if length doesn't match, early continue
        if ( rec->kn != key_sz ) continue;
        // compare the keys
        if (!strncmp( &(cfg->buffer[rec->k0]), key, key_sz )) {
            return rec;
        }
    }
    // nothing found
    return NULL;
}

char *mincf_export_rec(miniconf *cfg, mincf_rec *rec, char *buf, size_t sz) {
    size_t n = (rec->vn < sz-1) ? rec->vn : sz-1;
    return strncpy(buf, &(cfg->buffer[rec->v0]), n);
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
