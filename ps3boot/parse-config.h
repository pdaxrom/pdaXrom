#ifndef _PARSE_KBOOT_H_
#define _PARSE_KBOOT_H_

#include "devices.h"

int kboot_conf_read(char *dev_path, boot_device *dev);
int yaboot_conf_read(char *dev_path, boot_device *dev);
int ps3boot_conf_read(char *dev_path, boot_device *dev);

#endif
