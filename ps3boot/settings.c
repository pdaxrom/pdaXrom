#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "settings.h"

#define FLASHUTIL_BIN		"/usr/sbin/ps3-flash-util"

#define DB_OWNER_PS3BOOT	"3"

static int f_ready = 0;

int db_database_init(void)
{
    struct stat s;
    if (stat(FLASHUTIL_BIN, &s))
	return 1;
    int rc = system(FLASHUTIL_BIN " -T");
    if (rc)
	rc = system(FLASHUTIL_BIN " -F");
    if (rc) {
	fprintf(stderr, "database init error!\n");
	return 1;
    }

    f_ready = 1;

    return 0;
}

int db_database_close(void)
{
    f_ready = 0;
    
    return 0;
}

int db_database_get(char *key, u_int32_t *val)
{
    char buf[1024];
    
    if (!f_ready)
	return 1;
    
    snprintf(buf, 1024, FLASHUTIL_BIN " -P " DB_OWNER_PS3BOOT " %s", key);
    *val = 0;
    FILE *fp = popen(buf, "r");
    if (!fp) {
	fprintf(stderr, "database get - popen failed: %s\n", buf);
	return 1;
    }
    
    char *ptr = fgets(buf, 1024, fp);
    
    if (pclose(fp) == -1) {
	fprintf(stderr, "database get - pclose failed\n");
	return 1;
    }
    
    if (!ptr) {
	fprintf(stderr, "database get - no key\n");
	return 1;
    }
	
    if (!strlen(ptr)) {
	fprintf(stderr, "database get - empty string\n");
	return 1;
    }
    
    long long val_ll = 0;
    
    sscanf(ptr, "%Li", &val_ll);
    
    *val = val_ll;
    
    return 0;
}

int db_database_set(char *key, u_int32_t val)
{
    char buf[1024];
    long long val_ll = val;
    
    if (!f_ready)
	return 1;

    snprintf(buf, 1024, FLASHUTIL_BIN " -W " DB_OWNER_PS3BOOT " %s %Li", key, val_ll);
    int rc = system(buf);
    if (rc) {
	fprintf(stderr, "database set - error\n");
	return 1;
    }
    return 0;
}
