# Agent Instructions: Customfs

## Role

You are implementing a small early-boot platform for an appliance-style Ubuntu system. The first milestone is a custom initramfs that can boot independently, search for a future Ubuntu root filesystem, and fall back to a rescue shell if that root filesystem is absent.

## Hard constraints

- Keep milestone 1 simple.
- Do not require an Ubuntu `base_os` rootfs yet.
- Build using the kernel and modules already present on the target server.
- Avoid hard-coded disk names such as `/dev/sda`, `/dev/nvme0n1`, or `/dev/mmcblk0`.
- Prefer filesystem labels and `/dev/disk/by-label/*`.
- The first boot test should intentionally fail to find `base_os` and drop to rescue shell.
- Do not add overlayfs support until the fallback initramfs is proven.
- Do not add FIPS, STIG, signing, or update engine logic in milestone 1.

## Milestone 1 success criteria

Booting the generated initramfs should show:

```text
=== Customfs initramfs ===
Looking for Ubuntu rootfs at: /dev/disk/by-label/base_os
ERROR: base_os device not found.
Dropping to rescue shell.
/ #
```

This proves:

- the kernel boots
- the initramfs runs
- `/proc`, `/sys`, and `/dev` mount correctly
- storage discovery does not hard-fail
- rescue shell works

## Implementation expectations

Use BusyBox as the minimal rescue userspace.

The initramfs should include:

```text
/init
/bin/busybox
/bin/sh
/bin/mount
/bin/umount
/bin/ls
/bin/cat
/bin/dmesg
/sbin/switch_root
/sbin/blkid
/proc
/sys
/dev
/tmp
/mnt/base_os
/mnt/newroot
```

The `/init` script should:

1. set `PATH=/bin:/sbin`
2. mount `proc`, `sysfs`, and `devtmpfs`
3. print diagnostics
4. inspect `/proc/cmdline`
5. support `rescue=1`
6. look for `/dev/disk/by-label/base_os`
7. if missing, print block-device diagnostics and start `/bin/sh`
8. if present, mount it read-only
9. verify `/sbin/init` exists in the mounted rootfs
10. call `switch_root`
11. fall back to shell if anything fails

## Future milestones, not for first implementation

- Add `storage_space` partition discovery
- Add overlayfs assembly
- Add boot state metadata
- Add update staging
- Add rollback selection
- Add platform manifests
- Add standard/FIPS/STIG platform generations
- Add signature verification

## Design direction

Think of this as a boot platform, not simply an initramfs. The initramfs will eventually become the early boot control plane that selects and assembles the operating system, but milestone 1 should remain a minimal rescue-capable proof of life.
