MMCU=atmega328p
F_CPU=16000000
PROG=arduino
PROG_PORT=/dev/ttyUSB0

TARGET=main.hex

OBJ=TVout/video_gen.o TVout/TVout.o TVout/TVoutPrint.o TVoutfonts/font8x8.o TVoutfonts/font4x6.o
OBJ+=sound.o gfx.o bootlogo.o levels.o

FORMAT=ihex
OBJCOPY=avr-objcopy
OBJSIZE=avr-size
CC=avr-gcc
CPP=avr-g++
CPPFLAGS=-mmcu=$(MMCU) -I. -I TVout -I TVoutfonts -gdwarf-2 -DF_CPU=$(F_CPU)UL -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums -Wall -Wextra -pedantic -Wundef -Wundef -lm -ffunction-sections -fdata-sections -mstrict-X -maccumulate-args -Wl,--gc-sections -Wno-narrowing
CFLAGS=-mmcu=$(MMCU) -I. -I TVout -I TVoutfonts -gdwarf-2 -DF_CPU=$(F_CPU)UL -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums -Wall -Wextra -pedantic -Wundef -std=gnu11 -Wundef -lm
CFLAGS+=-ffunction-sections -fdata-sections -mstrict-X -maccumulate-args -Wl,--gc-sections

all: $(TARGET)

clean:
	rm -f $(TARGET)

flash: $(TARGET)
	sudo avrdude -U flash:w:$(TARGET):i -C /etc/avrdude.conf -v -p $(MMCU) -b 57600 -c $(PROG) -P $(PROG_PORT)

%.hex: %.elf
	$(OBJCOPY) -O $(FORMAT) -R .eeprom $< $@

%.elf: %.o $(OBJ)
	$(CC) $(CFLAGS) $^ --output $@
	$(OBJSIZE) --format=avr --mcu=$(MMCU) $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.cpp
	$(CPP) $(CPPFLAGS) -c $< -o $@

%.s: %.c
	$(CC) $(CFLAGS) -S -c $< -o $@
