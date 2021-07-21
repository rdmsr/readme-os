KERNEL := kernel.elf

CC = x86_64-elf-gcc
LD = x86_64-elf-ld

CFLAGS = -Wall -Wextra -O2 -pipe
LDFLAGS =

INTERNALLDFLAGS :=         \
	-Tbuild/linker.ld            \
	-nostdlib              \
	-zmax-page-size=0x1000 \
	-static                \
	-pie                   \
	--no-dynamic-linker    \
	-ztext

INTERNALCFLAGS  :=       \
	-Iinclude/                 \
	-std=c11          \
	-ffreestanding       \
	-fno-stack-protector \
	-fno-pic -fpie       \
	-mno-80387           \
	-mno-mmx             \
	-mno-3dnow           \
	-mno-sse             \
	-mno-sse2            \
	-mno-red-zone

ORGFILES := README.org
CFILES :=  main.c
OBJ    := main.o

ISO_IMAGE = disk.iso

.PHONY: clean all run

all: $(ISO_IMAGE)

run: $(ISO_IMAGE)
	qemu-system-x86_64 -M q35 -m 2G -cdrom $(ISO_IMAGE) -enable-kvm

limine:
	git clone https://github.com/limine-bootloader/limine.git --branch=v2.0-branch-binary --depth=1
	make -C limine

kernel.elf: $(OBJ)
	$(LD) $(OBJ) $(LDFLAGS) $(INTERNALLDFLAGS) -o $@

main.c:
	emacs --script build/build.el README.org

.PHONY: all clean

all: $(KERNEL)

include/stivale2.h:
	cd include && wget https://github.com/stivale/stivale/raw/master/stivale2.h && cd ..

main.o: $(CFILES) include/stivale2.h
	$(CC) $(CFLAGS) $(INTERNALCFLAGS) -c $< -o $@

$(ISO_IMAGE): limine  $(KERNEL)
	rm -rf iso_root
	mkdir -p iso_root
	@cp kernel.elf \
		limine.cfg limine/limine.sys limine/limine-cd.bin limine/limine-eltorito-efi.bin iso_root/  > /dev/null 2>&1
	@xorriso -as mkisofs -b limine-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		--efi-boot limine-eltorito-efi.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		iso_root -o $(ISO_IMAGE) > /dev/null 2>&1
	limine/limine-install $(ISO_IMAGE)
	rm -rf iso_root

clean:
	rm -f $(ISO_IMAGE)
	rm -rf $(KERNEL) $(OBJ) $(CFILES)
