
ISO_IMAGE = disk.iso

.PHONY: clean all run

all: $(ISO_IMAGE)

run: $(ISO_IMAGE)
	qemu-system-x86_64 -M q35 -m 2G -cdrom $(ISO_IMAGE) -enable-kvm

limine:
	git clone https://github.com/limine-bootloader/limine.git --branch=v2.0-branch-binary --depth=1
	make -C limine

src/kernel.elf:
	$(MAKE) -C src

$(ISO_IMAGE): limine src/kernel.elf
	rm -rf iso_root
	mkdir -p iso_root
	@cp src/kernel.elf \
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
	$(MAKE) -C src clean
