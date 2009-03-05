#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <ctype.h>

#include "parse-config.h"
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
    char *val = strchr(ptr, '=');
    if (!val)
	return NULL;
    val++;
    
    while ((*val != 0) && ((*val <= ' ') || (*val == '"') || (*val == '\'')))
	val++;
    
    ptr = val + strlen(val);

    while ((ptr >= val) && ((*ptr <= ' ') || (*ptr == '"') || (*ptr == '\'')))
	*ptr-- = 0;

    if (!strlen(val))
	return NULL;

    return strdup(val);
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

int yaboot_conf_read(char *dev_path, boot_device *dev)
{
    char buf[1024];
    snprintf(buf, 1024, MOUNT_DIR "%s/etc/yaboot.conf", dev_path);
    
    FILE *f = fopen(buf, "rb");
    if (f) {
	while (fgets(buf, 1024, f)) {
	    char *ptr = buf;
	    if ((*ptr == '#') ||
		(*ptr == ';'))
		continue;
	    if (!strncmp(ptr, "timeout", 7))
		dev->timeout = get_int_val(ptr);
	    else if (!strncmp(ptr, "default", 7))
		dev->def = get_str_val(ptr);
	    else if (!strncmp(ptr, "init-message", 12)) {
		char *msg = get_str_val(ptr);
		char *ptr = msg;
		while(*ptr) {
		    if ((ptr[0] == '\\') && (ptr[1] == 'n')) {
			strcpy(ptr, ptr + 1);
			*ptr = 0xa;
		    }
		    ptr++;
		}
		dev->message = msg;
	    } else if (!strncmp(ptr, "image", 5)) {
		char *label = NULL;
		char *initrd = NULL;
		char *cmdline = (char *) alloca(1024);
		char *kernel = get_str_val(ptr);
		while (fgets(buf, 1024, f)) {
		    char *ptr = buf;
		    if (*ptr > ' ')
			break;
		    while ((*ptr != 0) && (*ptr <= ' '))
			ptr++;
		    if (!strlen(ptr))
			break;
		    if (!strncmp(ptr, "label", 5))
			label = get_str_val(ptr);
		    else if (!strncmp(ptr, "append", 6)) {
			char *tmp = get_str_val(ptr);
			strcat(cmdline, tmp);
			strcat(cmdline, " ");
			free(tmp);
		    } else if (!strncmp(ptr, "root", 4)) {
			char *tmp = get_str_val(ptr);
			strcat(cmdline, "root=");
			strcat(cmdline, tmp);
			strcat(cmdline, " ");
			free(tmp);
		    } else if (!strncmp(ptr, "ramdisk", 7)) {
			char *tmp = get_str_val(ptr);
			strcat(cmdline, "ramdisk=");
			strcat(cmdline, tmp);
			strcat(cmdline, " ");
			free(tmp);
		    } else if (!strncmp(ptr, "initrd-size", 11)) {
			char *tmp = get_str_val(ptr);
			strcat(cmdline, "ramdisk_size=");
			strcat(cmdline, tmp);
			strcat(cmdline, " ");
			free(tmp);
		    } else if (!strncmp(ptr, "read-only", 9))
			strcat(cmdline, "ro ");
		    else if (!strncmp(ptr, "read-write", 10))
			strcat(cmdline, "rw ");
		    else if (!strncmp(ptr, "novideo", 7))
			strcat(cmdline, "video=ofonly ");
		    else if (!strncmp(ptr, "initrd", 6))
			initrd = get_str_val(ptr);
		}
		if (label)
		    bootdevice_add_config(dev, label, kernel, initrd, strdup(cmdline));
	    }
	}
	fclose(f);
	return 0;
    }
    
    return 1;
}
