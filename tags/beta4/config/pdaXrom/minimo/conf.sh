HOST_LDFLAGS=-L/usr/lib -L/usr/local/lib -L/usr/X11R6/lib HOST_CFLAGS=-I/usr/include -I/usr/local/include -I/usr/X11R6/include -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include LDFLAGS=-L/opt/arm/3.3.2/armv5tel-cacko-linux/X11R6/lib -Wl,-rpath-link,/opt/arm/3.3.2/armv5tel-cacko-linux/X11R6/lib ./configure --prefix=/usr/lib/mozilla --target=armv5tel-cacko-linux --build=i686-linux --x-includes=/opt/arm/3.3.2/armv5tel-cacko-linux/X11R6/include --x-libraries=/opt/arm/3.3.2/armv5tel-cacko-linux/X11R6/lib