#include <stdio.h>
#include <string.h>
#include "netconfig.h"
#include "netdevices.h"
#include "readconf.h"

#define CONF_PATH	"test"

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

int read_net_config(const char *iface)
{
    char buf[256];
    char val[256];
    
    sprintf(buf, CONF_PATH "/%s.conf", iface);
    if (readconf(buf, "ipaddr", val))
	ipaddrBox->text(val);
    else
	ipaddrBox->text("");
	
    return 0;
}

int write_net_config(void)
{
}

void editButton(fltk::Button*, void*)
{
    fprintf(stderr, "--%d %s\n", devList->value(), devList->item()->label());
    read_net_config(devList->item()->label());
    interfaceWindow->label(devList->item()->label());
    interfaceWindow->show();
}
