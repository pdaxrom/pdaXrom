#ifndef __UINPUTDEV_H__
#define __UINPUTDEV_H__

#include <linux/input.h>
#include <linux/uinput.h>

struct conf {
    int	fd;
    struct uinput_user_dev dev;
};

#if defined (__cplusplus)
extern "C" {
#endif

int uinput_open(struct conf *conf);

int uinput_close(struct conf *conf);

int uinput_send(struct conf *conf, __u16 type, __u16 code, __s32 value);

#if defined (__cplusplus)
}
#endif

#endif
