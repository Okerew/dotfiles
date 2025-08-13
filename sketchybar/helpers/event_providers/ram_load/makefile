CC = clang
CFLAGS = -Wall -Wextra -O2
TARGET = ram_load
SOURCE = ram_load.c

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)

clean:
	rm -f $(TARGET)

install: $(TARGET)
	mkdir -p bin
	mv $(TARGET) bin/

.PHONY: clean install
