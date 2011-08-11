.PHONY: libdance

VERSION=$(shell LANG=en_US svn info 2>&1 | grep Revision | awk '{print $$2}')

DATE=$(shell LANG=en_US date -R)

SYSTEM	:=x11
ifeq (linuxfb, $(SYSTEM))
TARGET	= dancesplashfb
else
TARGET	= dancesplash
endif
DATADIR	:=/usr/share/$(TARGET)
$DATADIR	:=./
OPT_CFLAGS:=-O2
#OPT_CFLAGS:=-g

all: libdance $(TARGET)

libdance:
	make -C libdance DATADIR=$(DATADIR) OPT_CFLAGS=$(OPT_CFLAGS)

CC	:= gcc
INSTALL	:= install

CFLAGS	= $(OPT_CFLAGS) -Wall -g `freetype-config --cflags` -fPIC -Ilibdance
CFLAGS	+= -DDATADIR=\"$(DATADIR)\" -DCONFIG_FILE=\"/etc/$(TARGET).conf\"

ifneq (linuxfb, $(SYSTEM))
CFLAGS  += -DUSE_X11
LDFLAGS	+= $(OPT_LDFLAGS) -pthread -Llibdance -ldance -ljpeg -lpng -lfreetype -lz -lm -lX11 -g
else
CFLAGS  += -DUSE_FB
LDFLAGS	+= $(OPT_LDFLAGS) -pthread -Llibdance -ldance -Wl,-Bstatic -ljpeg -lpng -lfreetype -lz -Wl,-Bdynamic -lm -g
endif

OBJS	= main.o

$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

install:
	$(INSTALL) -D -m 755 $(TARGET) $(DESTDIR)/usr/bin/$(TARGET)
	$(INSTALL) -D -m 644 fonts/Vera.ttf $(DESTDIR)/$(DATADIR)/fonts/Vera.ttf
	find artwork -type f -exec $(INSTALL) -D -m 644 {} $(DESTDIR)/$(DATADIR)/{} \;
	find $(DESTDIR)/$(DATADIR) -type d -name ".svn" | xargs rm -rf

deb:
	cp debian/changelog.in debian/changelog
	sed -i -e "s|@VERSION@|1.0.0-${VERSION}|" debian/changelog
	sed -i -e "s|@DATE@|${DATE}|" debian/changelog
	dpkg-buildpackage -rfakeroot -b -tc || true
	rm -f debian/changelog debian/files debian/dancesplashfb.debhelper.log debian/dancesplashfb.substvars
	rm -rf debian/dancesplashfb

clean:
	make -C libdance clean
	rm -f $(OBJS) $(TARGET)
