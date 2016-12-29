#include <miniconf.h>
#include <stdio.h>
#include <stdlib.h>
#include "common.h"

int main() {
    miniconf cfg;
    int result;
    result = mincf_read(&cfg,"nonexistent.cfg");
    test( result != MINCF_OK );
    test( result | MINCF_ERROR );
    test( result | MINCF_FILE_NOT_FOUND );
    mincf_free(&cfg);
    return 0;
}
