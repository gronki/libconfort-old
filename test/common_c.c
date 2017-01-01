#include "common.h"

int test0(char *file, unsigned int line, int expr, char *descr) {
    printf("%s has %s the test (line %d): %s\n",
        file, expr ? "PASSED" : "FAILED",
        line, descr);
    return expr;
}
