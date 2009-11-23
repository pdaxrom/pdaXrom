TARGET	= netconfig

all: $(TARGET)

CC	:= gcc

LIBS	:= $(shell pkg-config --cflags --libs gtk+-2.0)
CFLAGS	:=-Wall -g -export-dynamic $(shell pkg-config --cflags gtk+-2.0)

OBJS	= netconfig.o
UIFILES	= netconfig.ui

$(TARGET): $(OBJS) $(UIFILES)
	$(CC) -o $@ $(OBJS) $(LIBS) $(CFLAGS)

%.ui: %.glade
	gtk-builder-convert $< $@

clean:
	rm -f $(OBJS) $(UIFILES) $(TARGET)
