TARGET = ps3boot

HELPER = ps3boot-udev

SYSTEM=linuxfb

PREFIX=/usr
DATADIR=/usr/share/ps3boot

ifeq (linuxfb, $(SYSTEM))
UI_OBJ = ui-linuxfb.o
else
UI_OBJ = ui-x11.o
LDFLAGS = -lX11
endif

all: $(TARGET) $(HELPER)

OBJS = jpegdec.o pngdec.o image.o font.o message.o util.o devices.o main.o parse-kboot.o settings.o $(UI_OBJ) server.o
HELPER_OBJS = ps3boot-udev.o

OPT_CFLAGS:=-O2
CFLAGS = $(OPT_CFLAGS) -Wall -g `freetype-config --cflags`
#CFLAGS += -DDATADIR=\"/usr/share/ps3boot/\"
CFLAGS += -DDATADIR=\"$(DATADIR)\"
LDFLAGS += $(OPT_LDFLAGS) -ljpeg -lpng `freetype-config --libs` -g

$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

$(HELPER): $(HELPER_OBJS)
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f $(OBJS) $(TARGET) $(HELPER_OBJS) $(HELPER) *.o

install:
	install -D -m 755 ps3boot $(DESTDIR)$(PREFIX)/sbin/ps3boot
	install -D -m 755 ps3boot-udev $(DESTDIR)$(PREFIX)/sbin/ps3boot-udev
	install -D -m 644 utils/99-ps3boot.rules $(DESTDIR)/etc/udev/rules.d/99-ps3boot.rules
	for f in artwork/*.* fonts/Vera.ttf; do \
	    install -D -m 644 $$f $(DESTDIR)$(DATADIR)/$$f; \
	done

