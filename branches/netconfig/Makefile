PREFIX=/usr

INSTALL=install

LIBS=`fltk2-config --use-images  --ldflags`
CFLAGS=-O2 -Wall
ifneq (mingw, $(SYSTEM))
CFLAGS += -DPREFIX_ETC=\"$(PREFIX)/etc\" -DPREFIX=\"$(PREFIX)\"
LIBS += -lutil
EXESUFFIX=
else
CFLAGS += -DPREFIX_ETC=\"etc\"
LIBS += -lwsock32
EXESUFFIX=.exe
endif
CXXFLAGS=$(CFLAGS) `fltk2-config --use-images --cxxflags`

TARGET=netconfig

# Build commands and filename extensions...
.SUFFIXES:	.0 .1 .3 .c .cxx .h .fl .man .o .z $(EXEEXT)

.c.o:
	$(CC) -I.. -I../fltk/compat $(CFLAGS) -c $<

.cxx.o:
	$(CXX) -I.. -I../fltk/compat $(CXXFLAGS) -c $<

#CFILES = tclient.c

CPPFILES = netconfig.cxx netdevices.cxx

OBJECTS =	$(CPPFILES:.cxx=.o) $(CFILES:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LIBS)

install: $(TARGET)
	$(INSTALL) -D -m 755 $(TARGET) $(DESTDIR)$(PREFIX)/bin/$(TARGET)
	$(INSTALL) -D -m 644 logo.png  $(DESTDIR)$(PREFIX)/etc/logo.png

clean:
	rm -f $(OBJECTS) $(TARGET)
