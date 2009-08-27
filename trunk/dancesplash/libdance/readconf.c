#include <stdio.h>
#include <string.h>
#include <syslog.h>
#include <stdlib.h>

int db_readconf(char *fname, char *name, char *out)
{
    char rbuf[1024];
    FILE *f;

    out[0] = 0;

    f = fopen(fname, "rb");
    if (!f) {
        fprintf(stderr, "no such config file: '%s'\n", fname);
	return 0;
    }

    while (fgets(rbuf, 1024, f)) {
        char *buf = rbuf;
        while(*buf && (*buf <= ' '))
            buf++;

        if (*buf == '#')
            continue;

        if (!strncmp(name, buf, strlen(name))) {
            char *ptr = buf + strlen(buf);
            while ((ptr > buf) && (*ptr <= ' '))
                *ptr-- = 0;

            ptr = buf + strlen(name);
            while (*ptr && (*ptr <= ' '))
                ptr++;          

            strncpy(out, ptr, 256);
        }
    }

    fclose(f);

    if (!strlen(out)) {
        printf("can't find variable: '%s' in config file: '%s'\n", name, fname);
    }
    return strlen(out);
}
