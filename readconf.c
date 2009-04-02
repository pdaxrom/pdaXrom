#include <stdio.h>
#include <string.h>

char *readconf(char *fname, char *name, char *out)
{
    char rbuf[1024];
    FILE *f;
    
    out[0] = 0;
    
    f = fopen(fname, "rb");
    if (!f) {
	fprintf(stderr, "no such config file\n");
	return NULL;
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
	    
	    strcpy(out, ptr);
	}
    }

    if (!strlen(out))
	return NULL;
    
    fclose(f);
    return out;
}

/*
int main(int argc, char *argv[])
{
    char buf[1024];
    
    fprintf(stderr, "-- '%s'\n", read_conf("test.conf", "database", buf));

    return 0;
}
*/
