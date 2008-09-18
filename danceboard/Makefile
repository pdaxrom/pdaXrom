TARGET = danceboard

all: $(TARGET)

OBJS = jpegdec.o pngdec.o image.o dotdesktop.o board.o font.o util.o main.o

CFLAGS = $(OPT_CFLAGS) -Wall -g `freetype-config --cflags`
CFLAGS += -DDATADIR=\"/usr/share\"
#CFLAGS += -DDATADIR=\"./\"
LDFLAGS = $(OPT_LDFLAGS) -ljpeg -lpng -lX11 `freetype-config --libs` -g

$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

clean:
	rm -f $(OBJS) $(TARGET)

