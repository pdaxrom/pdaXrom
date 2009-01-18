TARGET = danceboard

SYSTEM:=`uname`

ifeq (Linux, $(SYSTEM))
UI_OBJ = ui-linuxfb.o
else
UI_OBJ = ui-x11.o
LDFLAGS = -lX11
endif

all: $(TARGET)

OBJS = jpegdec.o pngdec.o image.o font.o util.o devices.o main.o parse-kboot.o $(UI_OBJ)

OPT_CFLAGS:=-O2
CFLAGS = $(OPT_CFLAGS) -Wall -g `freetype-config --cflags`
#CFLAGS += -DDATADIR=\"/usr/share\"
CFLAGS += -DDATADIR=\"./\"
LDFLAGS += $(OPT_LDFLAGS) -ljpeg -lpng `freetype-config --libs` -g

$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

clean:
	rm -f $(OBJS) $(TARGET)

