# Customfs

Customfs is an early boot platform experiment for building a small, custom initramfs that can discover a future Ubuntu `base_os` root filesystem and fall back to a rescue shell when it is missing or invalid.

The first milestone intentionally does **not** require an Ubuntu rootfs. It proves that the kernel and initramfs can boot independently and provide a rescue environment.

## Initial goal

```text
UEFI/GRUB
  -> Linux kernel from the target server
  -> custom initramfs
  -> look for /dev/disk/by-label/base_os
  -> if missing, drop to rescue shell
```

## Project layout

```text
.
├── AGENT.md
├── Makefile
├── README.md
├── configs/
│   └── default.conf
├── docs/
│   ├── architecture.md
│   ├── layout-v1.md
│   └── roadmap.md
├── initramfs/
│   └── init
└── scripts/
    ├── build-initramfs.sh
    ├── install-deps.sh
    └── install-grub-test-entry.sh
```

## Build on the target server

```bash
sudo ./scripts/install-deps.sh
make
```

The output is written to:

```text
build/initrd-customfs.img
```

## Install a GRUB test entry

```bash
sudo ./scripts/install-grub-test-entry.sh
sudo update-grub
```

Then boot the `Customfs initramfs test` entry.

## Expected first result

Because `base_os` does not exist yet, the system should stop here:

```text
=== Customfs initramfs ===
ERROR: base_os device not found.
Dropping to rescue shell.
/ #
```

That is the desired first milestone.
