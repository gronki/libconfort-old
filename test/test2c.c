#include <miniconf.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    miniconf* cfg;
    FILE* f;
    char buf1[1024];
    char buf2[1024];
    char buf3[1024];
    size_t i;

    if ( (f = fopen("test2.cfg","r")) == NULL ) {
        fprintf(stderr,"failed opening file\n");
        return -1;
    }

    if (!(cfg = mincf_read(f))) {
        fprintf(stderr,"failed reading file\n");
        fclose(f);
        return -1;
    }
    fclose(f);


    for (size_t i = 1; i <= 6; i++) {
        sprintf(buf1,"%s%d", "key", i);
        sprintf(buf3,"default %d",  i);
        mincf_get_def(cfg,buf1,buf3,buf2,1024);
        printf("entry '%s' is '%s'.\n", buf1, buf2);
    }

    mincf_free(cfg);



}
