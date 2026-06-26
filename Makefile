.PHONY: all build clean deps grub-test

all: build

build:
	./scripts/build-initramfs.sh

deps:
	sudo ./scripts/install-deps.sh

grub-test:
	sudo ./scripts/install-grub-test-entry.sh

clean:
	rm -rf build
