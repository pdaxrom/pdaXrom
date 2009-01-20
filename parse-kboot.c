#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <ctype.h>

#include "parse-kboot.h"
#include "devices.h"

static void bootdevice_add_config(boot_device *dev, char *label, char *kernel, char *initrd, char *cmdline)
{
    boot_config *tmp = (boot_config *) malloc(sizeof(boot_config));
    tmp->label = label;
    tmp->kernel = kernel;
    tmp->initrd = initrd;
    tmp->cmdline = cmdline;
    tmp->next = NULL;
    
    if (dev->conf) {
	boot_config *tmp2 = dev->conf;
	while (tmp2->next)
	    tmp2 = tmp2->next;
	tmp2->next = tmp;
    } else
	dev->conf = tmp;
}

static int get_int_val(char *ptr)
{
    int val = 0;
    ptr = strchr(ptr, '=');
    if (!ptr)
	return 0;
    sscanf(ptr + 1, "%d", &val);
    return val;
}

static char *get_str_val(char *ptr)
{
    char *buf = alloca(strlen(ptr));
    char *val = NULL;
    ptr = strchr(ptr, '=');
    if (!ptr)
	return NULL;
    ptr++;
    sscanf(ptr, "%s", buf);
    int len = strlen(buf);
    if (len) {
	val = (char *) malloc(strlen(buf) + 1);
	strcpy(val, buf);
    }
    return val;
}

int kboot_conf_read(char *dev_path, boot_device *dev)
{
    char buf[1024];
    snprintf(buf, 1024, MOUNT_DIR "%s/etc/kboot.conf", dev_path);
    
    FILE *f = fopen(buf, "rb");
    if (f) {
	while (fgets(buf, 1024, f)) {
	    char *ptr = buf;
	    if (*ptr == '#')
		continue;
	    if (!strncmp(ptr, "timeout", 7))
		dev->timeout = get_int_val(ptr);
	    else if (!strncmp(ptr, "message", 7)) {
		struct stat s;
		char *name = get_str_val(ptr);
		if (!name)
		    continue;
		snprintf(buf, 1024, MOUNT_DIR "%s%s", dev_path, name);
		if (!lstat(buf, &s)) {
		    FILE *fm = fopen(buf, "rb");
		    if (fm) {
			dev->message = (char *) malloc(s.st_size + 1);
			int l = fread(dev->message, 1, s.st_size, fm);
			dev->message[l] = 0;
			fclose(fm);
		    }
		}
		free(name);
	    } else if (!strncmp(ptr, "default", 7)) {
		dev->def = get_str_val(ptr);
	    } else {
		char *buf = alloca(strlen(ptr));
		char *cmdline_buf = alloca(strlen(ptr));
		char *label = NULL;
		char *kernel = NULL;
		char *initrd = NULL;
		char *cmdline = NULL;
		char *p1 = ptr + strlen(ptr) - 1;
		while (isspace(*p1) ||
		       (*p1 == '\'') ||
		       (*p1 == '"'))
		    *p1-- = 0;
		p1 = strchr(ptr, '=');
		if (p1) {
		    *p1++ = 0;
		    sscanf(ptr, "%s", buf);
		    label = strdup(buf);
		    while (isspace(*p1) ||
			   (*p1 == '\'') ||
			   (*p1 == '"'))
			p1++;
		    if (*p1) {
			sscanf(p1, "%s", buf);
			if (strchr(buf, ':'))
			    kernel = strdup(strchr(buf, ':') + 1);
			else
			    kernel = strdup(buf);
			*cmdline_buf = 0;
			while ((p1 = strchr(p1, ' '))) {
			    for (; isspace(*p1) && *p1; p1++);
			    sscanf(p1, "%s", buf);
			    if ((!strncmp(buf, "initrd=", 7)) &&
				(!initrd)) {
				if (strchr(buf + 7, ':'))
				    initrd = strdup(strchr(buf + 7, ':') + 1);
				else
				    initrd = strdup(buf + 7);
			    } else {
				strcat(cmdline_buf, buf);
				strcat(cmdline_buf, " ");
			    }
			}
		    }
		    cmdline_buf[strlen(cmdline_buf) - 1] = 0;
		    cmdline = strdup(cmdline_buf);
		    bootdevice_add_config(dev, label, kernel, initrd, cmdline);
		}
	    }
	}
	fclose(f);
	return 0;
    }
    
    return 1;
}
