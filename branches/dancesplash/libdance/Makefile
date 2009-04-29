TARGET	= dance

SYSTEM	:=x11

DATADIR	:=/usr/share/dance

ifeq (linuxfb, $(SYSTEM))
UI_OBJ	= ui-linuxfb.o
else
UI_OBJ	= ui-x11.o
LDFLAGS	= -lX11
endif

all: lib$(TARGET).a

OBJS	= jpegdec.o pngdec.o image.o font.o message.o util.o $(UI_OBJ)

CC	:= gcc
AR	:= ar
RANLIB	:= ranlib

#OPT_CFLAGS:=-O2
CFLAGS	= $(OPT_CFLAGS) -Wall -g `freetype-config --cflags` -fPIC
CFLAGS	+= -DDATADIR=\"$(DATADIR)\"
LDFLAGS	+= $(OPT_LDFLAGS) -ljpeg -lpng `freetype-config --libs` -g

lib$(TARGET).so: $(OBJS)
	$(CC) -shared -o $@ $^ $(CFLAGS) $(LDFLAGS)

lib$(TARGET).a: $(OBJS)
	$(AR) rcs $@ $^
	$(RANLIB) $@

clean:
	rm -f $(OBJS) $(TARGET) $(HELPER_OBJS) $(HELPER) *.o *.so* *.a

install: $(TARGET)

