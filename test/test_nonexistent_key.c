#include <miniconf.h>
#include <stdio.h>
#include <stdlib.h>
#include "common.h"

int main() {
    miniconf cfg;
    char buf[1024];
    if (test(mincf_read(&cfg,"test.cfg") == MINCF_OK)) {
        test(mincf_get(&cfg,"thiskeydoesnotexist",buf,sizeof(buf),NULL) != MINCF_OK);
        mincf_free(&cfg);
    }

    return 0;
}
