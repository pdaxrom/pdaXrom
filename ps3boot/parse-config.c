/*
 *
 * Debug parser:
 * gcc parse-config.c -o parse-config -DDEBUG_MAIN -I/usr/include/freetype2
 *
 */
 
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <ctype.h>

#include "parse-config.h"
#include "devices.h"

#ifdef DEBUG_MAIN
#undef MOUNT_DIR
#define MOUNT_DIR "./"
#endif

static void bootdevice_add_config(boot_device *dev, char *label, char *kernel, char *initrd, char *cmdline)
{
    boot_config *tmp = (boot_config *) malloc(sizeof(boot_config));
    tmp->label = label;
    tmp->kernel = kernel;
    tmp->initrd = initrd;
    tmp->cmdline = cmdline;
    tmp->next = NULL;

#ifdef DEBUG_MAIN
    fprintf(stderr, "add new %s\n\tkernel=%s\n\tinitrd=%s\n\tcmdline=%s\n", label, kernel, initrd, cmdline);
#endif
    
    if (dev->conf) {
	boot_config *tmp2 = dev->conf;
	while (tmp2->next)
	    tmp2 = tmp2->next;
	tmp2->next = tmp;
    } else
	dev->conf = tmp;
}

static void remove_tabs(char *ptr)
{
    char *val = ptr;
    while(*val) {
	if (*val == '\t') *val = ' ';
	val++;
    }
}

static int get_int_val(char *ptr, char del)
{
    int val = 0;
    remove_tabs(ptr);
    ptr = strchr(ptr, del);
    if (!ptr)
	return 0;
    sscanf(ptr + 1, "%d", &val);
    return val;
}

static char *get_str_val(char *ptr, char del)
{
    remove_tabs(ptr);
    char *val = strchr(ptr, del);
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
    const char *cfile[] = { "kboot.conf", "KBOOT.CONF", "kboot.cnf", "KBOOT.CNF", "kboot.cfg", "KBOOT.CFG", NULL };
    char buf[1024];
    FILE *f;
    int i = 0;

    while(1) {
	if (cfile[i] == NULL)
	    return 1;
	snprintf(buf, 1024, MOUNT_DIR "%s/etc/%s", dev_path, cfile[i]);
	f = fopen(buf, "rb");
	if (f)
	    break;
	i++;
    }

    if (f) {
	while (fgets(buf, 1024, f)) {
	    char *ptr = buf;
	    if (*ptr == '#')
		continue;
	    if (!strncmp(ptr, "timeout", 7))
		dev->timeout = get_int_val(ptr, '=');
	    else if (!strncmp(ptr, "message", 7)) {
		struct stat s;
		char *name = get_str_val(ptr, '=');
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
		dev->def = get_str_val(ptr, '=');
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
    const char *cfile[] = { "yaboot.conf", "YABOOT.CONF", "yaboot.cnf", "YABOOT.CNF", "yaboot.cfg", "YABOOT.CFG", NULL };
    char buf[1024];
    FILE *f;
    int i = 0;

    while(1) {
	if (cfile[i] == NULL)
	    return 1;
	snprintf(buf, 1024, MOUNT_DIR "%s/etc/%s", dev_path, cfile[i]);
#ifdef DEBUG_MAIN
	fprintf(stderr, "try to open %s\n", buf);
#endif
	f = fopen(buf, "rb");
	if (f)
	    break;
	i++;
    }

    if (f) {
	while (fgets(buf, 1024, f)) {
	    char *ptr = buf;
	    if ((*ptr == '#') ||
		(*ptr == ';'))
		continue;
	    if (!strncmp(ptr, "timeout", 7))
		dev->timeout = get_int_val(ptr, '=');
	    else if (!strncmp(ptr, "default", 7))
		dev->def = get_str_val(ptr, '=');
	    else if (!strncmp(ptr, "init-message", 12)) {
		char *msg = get_str_val(ptr, '=');
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
		char *kernel = get_str_val(ptr, '=');
		cmdline[0] = 0;
		while (fgets(buf, 1024, f)) {
		    char *ptr = buf;
		    if (*ptr > ' ')
			break;
		    while ((*ptr != 0) && (*ptr <= ' '))
			ptr++;
		    if (!strlen(ptr))
			break;
		    if (!strncmp(ptr, "label", 5))
			label = get_str_val(ptr, '=');
		    else if (!strncmp(ptr, "append", 6)) {
			char *tmp = get_str_val(ptr, '=');
			strcat(cmdline, tmp);
			strcat(cmdline, " ");
			free(tmp);
		    } else if (!strncmp(ptr, "root", 4)) {
			char *tmp = get_str_val(ptr, '=');
			strcat(cmdline, "root=");
			strcat(cmdline, tmp);
			strcat(cmdline, " ");
			free(tmp);
		    } else if (!strncmp(ptr, "ramdisk", 7)) {
			char *tmp = get_str_val(ptr, '=');
			strcat(cmdline, "ramdisk=");
			strcat(cmdline, tmp);
			strcat(cmdline, " ");
			free(tmp);
		    } else if (!strncmp(ptr, "initrd-size", 11)) {
			char *tmp = get_str_val(ptr, '=');
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
			initrd = get_str_val(ptr, '=');
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

int ps3boot_conf_read(char *dev_path, boot_device *dev)
{
    const char *cfile[] = { "ps3boot.conf", "PS3BOOT.CONF", "ps3boot.cfg", "PS3BOOT.CFG", NULL };
    char buf[1024];
    FILE *f;
    int i = 0;

    while(1) {
	if (cfile[i] == NULL)
	    return 1;
	snprintf(buf, 1024, MOUNT_DIR "%s/%s", dev_path, cfile[i]);
	f = fopen(buf, "rb");
	if (f)
	    break;
	i++;
    }
    
    if (f) {
	while (fgets(buf, 1024, f)) {
	    char *ptr = buf;
	    if ((*ptr == '#') ||
		(*ptr == ';'))
		continue;
	    if (!strncmp(ptr, "timeout", 7))
		dev->timeout = get_int_val(ptr, '=');
	    else if (!strncmp(ptr, "default", 7))
		dev->def = get_str_val(ptr, '=');
	    else if (!strncmp(ptr, "message", 7)) {
		char *msg = get_str_val(ptr, '=');
		char *ptr = msg;
		while(*ptr) {
		    if ((ptr[0] == '\\') && (ptr[1] == 'n')) {
			strcpy(ptr, ptr + 1);
			*ptr = 0xa;
		    }
		    ptr++;
		}
		dev->message = msg;
	    } else if (!strncmp(ptr, "label", 5)) {
		char *cmdline = (char *) alloca(1024);
		char *label = get_str_val(ptr, '=');
		cmdline[0] = 0;
		while (fgets(buf, 1024, f)) {
		    char *ptr = buf;
		    if (*ptr > ' ')
			break;
		    while ((*ptr != 0) && (*ptr <= ' '))
			ptr++;
		    if (!strlen(ptr))
			break;
		    if (!strncmp(ptr, "exec", 4)) {
			char *tmp = get_str_val(ptr, '=');
			strcat(cmdline, tmp);
			strcat(cmdline, " ");
			free(tmp);
		    }
		}
		if (label)
		    bootdevice_add_config(dev, label, NULL, NULL, strdup(cmdline));
	    }
	}
	fclose(f);
	return 0;
    }
    
    return 1;
}

int syslinux_conf_read(char *dev_path, boot_device *dev)
{
    const char *cfile[] = { "isolinux/text.cfg", "ISOLINUX/TEXT.CFG",
			    "isolinux/isolinux.cfg", "ISOLINUX/ISOLINUX.CFG",
			    "syslinux.cfg", "SYSLINUX.CFG",
			    NULL
			  };
    char buf[1024];
    FILE *f;
    int i = 0;

    while(1) {
	if (cfile[i] == NULL)
	    return 1;
	snprintf(buf, 1024, MOUNT_DIR "%s/%s", dev_path, cfile[i]);
	f = fopen(buf, "rb");
	if (f)
	    break;
	i++;
    }

    char *work_dir = strdup(cfile[i]);
    char *ptr = strrchr(work_dir, '/');
    if (ptr)
	*++ptr = 0;
    else
	*work_dir = 0;

    if (f) {
	while (fgets(buf, 1024, f)) {
	  while(1) {
	    char *ptr = buf;
	    if ((*ptr == '#') ||
		(*ptr == ';'))
		continue;
//	    if (!strncasecmp(ptr, "timeout", 7))
//		dev->timeout = get_int_val(ptr, ' ');
//	    else if (!strncasecmp(ptr, "default", 7))
//		dev->def = get_str_val(ptr, ' ');
//	    else
	    if (!strncasecmp(ptr, "display", 7)) {
		struct stat s;
		char *name = get_str_val(ptr, ' ');
		if (!name)
		    continue;
		snprintf(buf, 1024, MOUNT_DIR "%s/%s%s", dev_path, work_dir, name);
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
	    } else if (!strncasecmp(ptr, "label", 5)) {
		char *kernel = NULL;
		char *initrd = NULL;
		char *cmdline = (char *) alloca(1024);
		char *label = get_str_val(ptr, ' ');
		cmdline[0] = 0;
		while (fgets(buf, 1024, f)) {
		    char *ptr = buf;
		    if (*ptr > ' ')
			break;
		    while ((*ptr != 0) && (*ptr <= ' '))
			ptr++;
		    if (!strlen(ptr))
			continue;
		    if (!strncasecmp(ptr, "kernel", 6)) {
			kernel = get_str_val(ptr, ' ');
		    } else if (!strncmp(ptr, "append", 6)) {
			char *tmp = get_str_val(ptr, ' ');
			strcat(cmdline, tmp);
			strcat(cmdline, " ");
			free(tmp);
		    }
		}
		initrd = strstr(cmdline, "initrd=");
		if (initrd) {
		    char *ptr = strdup(initrd);
		    char *end = strchr(ptr, ' ');
		    if (end)
			*end = 0;
		    initrd = get_str_val(ptr, '=');
		    free(ptr);
		}
		if (label)
		    bootdevice_add_config(dev, label, kernel, initrd, strdup(cmdline));
		continue;
	    }
	    break;
	  }
	}
	fclose(f);
	return 0;
    }
    
    return 1;
}

int grub_conf_read(char *dev_path, boot_device *dev)
{
    const char *cfile[] = { "boot/grub/menu.lst", NULL };
    char buf[1024];
    FILE *f;
    int i = 0;

    while(1) {
	if (cfile[i] == NULL)
	    return 1;
	snprintf(buf, 1024, MOUNT_DIR "%s/%s", dev_path, cfile[i]);
	f = fopen(buf, "rb");
	if (f)
	    break;
	i++;
    }

    if (f) {
	while (fgets(buf, 1024, f)) {
	    char *ptr = buf;
	    if ((*ptr == '#') ||
		(*ptr == ';'))
		continue;
	    if (!strncasecmp(ptr, "title", 5)) {
		char *kernel = NULL;
		char *initrd = NULL;
		char *cmdline= NULL;
		char *label = get_str_val(ptr, ' ');
		while (fgets(buf, 1024, f)) {
		    char *ptr = buf;
		    while ((*ptr != 0) && (*ptr <= ' '))
			ptr++;
		    if (!strlen(ptr))
			break;
		    if (!strncasecmp(ptr, "kernel", 6)) {
			kernel = get_str_val(ptr, ' ');
		    } else if (!strncmp(ptr, "initrd", 6)) {
			initrd = get_str_val(ptr, ' ');
		    }
		}
		if (kernel) {
		    cmdline = get_str_val(kernel, ' ');
		    char *end = strchr(kernel, ' ');
		    if (end) 
			*end = 0;
		}
		if (label)
		    bootdevice_add_config(dev, label, kernel, initrd, cmdline);
		continue;
	    }
	}
	fclose(f);
	return 0;
    }
    
    return 1;
}

#ifdef DEBUG_MAIN
int main(int argc, char *argv[])
{
    boot_device d;
    memset(&d, 0, sizeof(d));
    
    int ret = yaboot_conf_read(argv[1], &d);
    
    fprintf(stderr, "yaboot_conf_read return %d\n", ret);
    if (!ret) {
	fprintf(stderr, "message=%s\ndefault=%s\ntimeout=%d\n", d.message, d.def, d.timeout);
    }
    
    return 0;
}
#endif
