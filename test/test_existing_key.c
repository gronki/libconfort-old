#include <miniconf.h>
#include <stdio.h>
#include <stdlib.h>
#include "common.h"

int main() {
    miniconf cfg;
    char buf[1024];
    if (test(mincf_read(&cfg,"test.cfg") == MINCF_OK)) {
        if (test(mincf_get(&cfg,"key1",buf,sizeof(buf),NULL) == MINCF_OK)) {
            test(!strcmp(buf,"value1"));
        }
        mincf_free(&cfg);
    }

    return 0;
}
