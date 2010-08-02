HELPER = minimount-udev

all: $(HELPER)

CFLAGS=-O2 -Wall

HELPER_OBJS = minimount-udev.o

$(HELPER): $(HELPER_OBJS)
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f $(HELPER) $(HELPER_OBJS)

install:
	install -D -m 755 $(HELPER) $(DESTDIR)/usr/sbin/$(HELPER)
	install -D -m 644 95-minimount.rules $(DESTDIR)/etc/udev/rules.d/95-minimount.rules
	install -D -m 755 minimount $(DESTDIR)/usr/sbin/minimount

