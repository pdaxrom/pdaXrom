#include <stdio.h>
#include <string.h>
#include "netconfig.h"
#include "netdevices.h"
#include "readconf.h"

#define CONF_PATH	"test"

static char iface_curr[128];

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

    if (readconf(buf, "netmask", val))
	netmaskBox->text(val);
    else
	netmaskBox->text("255.255.255.0");

    if (readconf(buf, "gateway", val))
	gatewayBox->text(val);
    else
	gatewayBox->text("");

    if (readconf(buf, "dns1", val))
	dnsBox->text(val);
    else
	dnsBox->text("");

    if (readconf(buf, "dns2", val))
	dns2Box->text(val);
    else
	dns2Box->text("");
	
    return 0;
}

int write_net_config(void)
{
    return 0;
}

void editButton(fltk::Button*, void*)
{
    int i = devList->value();
    strcpy(iface_curr, devList->child(i)->label());
    fprintf(stderr, "--%d %s\n", i, iface_curr);
    read_net_config(iface_curr);
    interfaceWindow->label(iface_curr);
    interfaceWindow->show();
}

void saveInterface(fltk::ReturnButton*, void*)
{
    char buf[256];
    sprintf(buf, CONF_PATH "/%s.conf", iface_curr);
    FILE *f = fopen(buf, "wb");
    if (f) {
	fprintf(f, "ipaddr %s\n", ipaddrBox->text());
	fprintf(f, "netmask %s\n", netmaskBox->text());
	fprintf(f, "gateway %s\n", gatewayBox->text());
	fprintf(f, "dns1 %s\n", dnsBox->text());
	fprintf(f, "dns2 %s\n", dns2Box->text());
	fclose(f);
    }
    interfaceWindow->hide();
}
