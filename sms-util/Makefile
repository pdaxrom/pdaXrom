TARGET=sms-util

all: $(TARGET)

CFLAGS=-g -O2 -Wall

OBJS = sms-pdu.o

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(LFLAGS) $(LIBS) $^

clean:
	rm -f $(TARGET) *.o
