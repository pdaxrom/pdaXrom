TARGET	= netconfig

all: $(TARGET)

PREFIX	:= /usr
DATADIR	:= $(PREFIX)/share
RESDIR	:= $(DATADIR)/netconfig

CC	:= gcc
INSTALL	:= install

LIBS	:= $(shell pkg-config --cflags --libs gtk+-2.0)
CFLAGS	:=-Wall -g -export-dynamic $(shell pkg-config --cflags gtk+-2.0) -DRESDIR=\"$(RESDIR)\"

OBJS	= netconfig.o
UIFILES	= netconfig.ui

$(TARGET): $(OBJS) $(UIFILES)
	$(CC) -o $@ $(OBJS) $(LIBS) $(CFLAGS)

%.ui: %.glade
	gtk-builder-convert $< $@

clean:
	rm -f $(OBJS) $(UIFILES) $(TARGET)

install: $(TARGET)
	$(INSTALL) -D -m 755 netconfig $(DESTDIR)$(PREFIX)/bin/netconfig
	$(INSTALL) -D -m 644 netconfig.ui $(DESTDIR)$(RESDIR)/netconfig.ui
	$(INSTALL) -D -m 644 netconfig.desktop $(DESTDIR)$(DATADIR)/applications/netconfig.desktop
