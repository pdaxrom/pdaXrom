#!/bin/sh

make OPT_CFLAGS="-I/opt/local/include" OPT_LDFLAGS="-L/opt/local/lib -L/usr/X11R6/lib" $@
