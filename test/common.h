
#ifndef __COMMON_H__
#define __COMMON_H__
#include <stdlib.h>
#include <stdio.h>

#define test(x) test0(__FILE__,__LINE__,x,#x)
int test0(char *file, unsigned int line, int expr, char *descr);

#endif
