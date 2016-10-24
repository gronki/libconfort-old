#include <miniconf.h>
#include <stdio.h>
#include <stdlib.h>

int test_nonexistent_file() {
    miniconf cfg;
    int result;
    if (mincf_read(&cfg,"nonexistent.cfg") == MINCF_OK) {
        result = 0;
        mincf_free(&cfg);
    } else {
        result = 1;
    }
    return result;
}

int test_nonexistent_key() {
    miniconf cfg;
    int result = 0;
    char buf[1024];
    if (mincf_read(&cfg,"test.cfg") != MINCF_OK) {
        return 0;
    }

    result = (mincf_get(&cfg,"thiskeydoesnotexist",buf,sizeof(buf),NULL) != MINCF_OK);

    mincf_free(&cfg);
    return result;
}

int test_get_existing_key() {
    miniconf cfg;
    int result = 0;
    char buf[1024];
    if (mincf_read(&cfg,"test.cfg") != MINCF_OK) {
        return 0;
    }

    result = (mincf_get(&cfg,"key1",buf,sizeof(buf),NULL) == MINCF_OK);
    result = result && (!strcmp(buf,"value1"));

    mincf_free(&cfg);
    return result;
}

int test_get_existing_keydef() {

    miniconf cfg;
    int result = 0;
    char buf[1024];
    char defvalue[] = "bu bu buuu";
    if (mincf_read(&cfg,"test.cfg") != MINCF_OK) {
        return 0;
    }

    result = (mincf_get(&cfg,"thiskeyisnothere",buf,sizeof(buf),defvalue) == MINCF_OK);
    result = result && (!strcmp(buf,defvalue));

    printf("Expected \"%s\", got \"%s\".\n",defvalue,buf);

    mincf_free(&cfg);
    return result;
}

int main() {

    char ok_str[] = "OK";
    char fail_str[] = "FAILED!";
    int testnr=0;
    char fmtstring[] = "%-2d %-30s - %s\n";

    printf(fmtstring, ++testnr,
        "test_nonexistent_file",
        test_nonexistent_file() ? ok_str : fail_str);

    printf(fmtstring, ++testnr,
        "test_nonexistent_key",
        test_nonexistent_key() ? ok_str : fail_str);

    printf(fmtstring, ++testnr,
        "test_get_existing_key",
        test_get_existing_key() ? ok_str : fail_str);
        
    printf(fmtstring, ++testnr,
        "test_get_existing_keydef",
        test_get_existing_keydef() ? ok_str : fail_str);

    printf("%s\n", "ALL TESTS DONE");

    return 0;

}
