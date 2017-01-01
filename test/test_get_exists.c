#include <miniconf.h>
#include <stdio.h>
#include <stdlib.h>
#include "common.h"

int main() {
    miniconf cfg;
    int ret;

    if (test(mincf_read(&cfg,"test.cfg") == MINCF_OK)) {

        ret = mincf_exists(&cfg,"thiskeydoesnotexist");
        test( ret != MINCF_OK );
        test( (ret & MINCF_ERROR) == 0 );
        test( (ret & MINCF_NOT_FOUND) != 0 );

        ret = mincf_exists(&cfg,"key6");
        printf("%s %04x\n","MINCF_OK",MINCF_OK);
        printf("%s %04x\n","MINCF_ERROR",MINCF_ERROR);
        printf("%s %04x\n","MINCF_NOT_FOUND",MINCF_NOT_FOUND);
        test( ret == MINCF_OK );
        test( (ret & MINCF_ERROR) == 0 );
        test( (ret & MINCF_NOT_FOUND) == 0 );

        mincf_free(&cfg);
    }

    return 0;
}
