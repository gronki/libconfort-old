#include <miniconf.h>
#include <stdio.h>
#include <stdlib.h>
#include "common.h"

int main() {

    miniconf cfg;
    char buf[1024];
    char defvalue[] = "bu bu buuu";

    if (test(mincf_read(&cfg,"test.cfg") == MINCF_OK)) {
        if (test(mincf_get(&cfg,"thiskeyisnothere",buf,sizeof(buf),defvalue) == MINCF_OK)) {
            test(!strcmp(buf,defvalue));
        }
    }

    mincf_free(&cfg);
}
