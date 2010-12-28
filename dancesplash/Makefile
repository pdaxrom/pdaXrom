.PHONY: libdance

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


clean:
	make -C libdance clean
	rm -f $(OBJS) $(TARGET)
