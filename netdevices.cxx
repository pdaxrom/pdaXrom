#include <stdio.h>
#include <string.h>
#include "netconfig.h"
#include "netdevices.h"

int add_devices(void)
{
    char buf[1024];
    FILE *f = fopen("/proc/net/dev", "r");
    if (!f)
	return -1;

    char *res = fgets(buf, sizeof(buf), f);
    res = fgets(buf, sizeof(buf), f);

    while (fgets(buf, sizeof(buf), f)) {
	res = strchr(buf, ':');
	if (res) {
	    *res = 0;
	    res = buf;
	    while (*res == ' ') res++;
	    if (strcmp(res, "lo"))
	        devList->add(res);
	}
    }

    fclose(f);
    return 0;
}
