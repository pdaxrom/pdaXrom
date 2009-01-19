TARGET = ps3boot

HELPER = ps3boot-udev

SYSTEM=
DATADIR=./

ifeq (linuxfb, $(SYSTEM))
UI_OBJ = ui-linuxfb.o
else
UI_OBJ = ui-x11.o
LDFLAGS = -lX11
endif

all: $(TARGET) $(HELPER)

OBJS = jpegdec.o pngdec.o image.o font.o message.o util.o devices.o main.o parse-kboot.o $(UI_OBJ) server.o
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

