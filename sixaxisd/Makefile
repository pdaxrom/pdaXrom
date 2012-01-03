TARGET = sixaxisd jstestx

all: $(TARGET)

CFLAGS = -O2 -Wall

OBJS = uinputdev.o sixsrv.o

$(TARGET): $(OBJS)
	$(CC) -o $@ $^

jstestx: jstest.o axbtnmap.o
	$(CC) -o $@ jstest.o axbtnmap.o

install:
	install -D -m 755 sixaxisd $(DESTDIR)/usr/bin/sixaxisd
	install -D -m 644 99-sixaxisd.rules $(DESTDIR)/etc/udev/rules.d/99-sixaxisd.rules
#	install -D -m 755 jstestx  $(DESTDIR)/usr/bin/jstestx

clean:
	rm -f $(OBJS) $(TARGET) jstestx *.o

distclean:
	rm -f $(OBJS) $(TARGET) jstestx *.o
