KERNEL := kernel.elf

CC = x86_64-elf-gcc
LD = x86_64-elf-ld

CFLAGS = -Wall -Wextra -O2 -pipe
LDFLAGS =

INTERNALLDFLAGS :=         \
	-Tlinker.ld            \
	-nostdlib              \
	-zmax-page-size=0x1000 \
	-static                \
	-pie                   \
	--no-dynamic-linker    \
	-ztext

INTERNALCFLAGS  :=       \
	-I.                  \
	-std=c2x           \
	-ffreestanding       \
	-fno-stack-protector \
	-fno-pic -fpie       \
	-mno-80387           \
	-mno-mmx             \
	-mno-3dnow           \
	-mno-sse             \
	-mno-sse2            \
	-mno-red-zone

ORGFILES := $(shell find ./ -type f -name '*.org')
CFILES :=  $(ORGFILES:.org=.c)
OBJ    := $(CFILES:.c=.o)

.PHONY: all clean

all: $(KERNEL)

stivale2.h:
	wget https://github.com/stivale/stivale/raw/master/stivale2.h

$(KERNEL): $(OBJ)
	$(LD) $(OBJ) $(LDFLAGS) $(INTERNALLDFLAGS) -o $@

%.o: $(CFILES) stivale2.h
	$(CC) $(CFLAGS) $(INTERNALCFLAGS) -c $< -o $@

%.c: %.org
	emacs --script build.el $^
clean:
	rm -rf $(KERNEL) $(OBJ) $(CFILES)
