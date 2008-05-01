TARGET = rcontrol

all: $(TARGET)

CFLAGS = -O2 -Wall

OBJS = uinputdev.o msp430lib.o main.o

$(TARGET): $(OBJS)
	$(CC) -o $@ $^

clean:
	rm -f $(OBJS) $(TARGET)
