#!/usr/bin/env bash
set -euo pipefail

# Fetch Ubuntu 24.04 kernel packages into build/kernel-packages.
# This script is intended to run on Ubuntu 24.04 or inside an Ubuntu 24.04 build container/chroot.
# It does not commit kernel binaries to git.

UBUNTU_CODENAME="${UBUNTU_CODENAME:-noble}"
KERNEL_FLAVOR="${KERNEL_FLAVOR:-generic}"
OUT_DIR="${OUT_DIR:-build/kernel-packages}"

mkdir -p "${OUT_DIR}"

if ! command -v apt-get >/dev/null 2>&1; then
    echo "ERROR: apt-get is required." >&2
    exit 1
fi

if ! command -v apt-cache >/dev/null 2>&1; then
    echo "ERROR: apt-cache is required." >&2
    exit 1
fi

case "${KERNEL_FLAVOR}" in
    generic)
        META_PKG="linux-image-generic"
        ;;
    generic-hwe)
        META_PKG="linux-generic-hwe-24.04"
        ;;
    *)
        echo "ERROR: unsupported KERNEL_FLAVOR=${KERNEL_FLAVOR}" >&2
        echo "Supported: generic, generic-hwe" >&2
        exit 1
        ;;
esac

echo "Ubuntu codename: ${UBUNTU_CODENAME}"
echo "Kernel flavor: ${KERNEL_FLAVOR}"
echo "Kernel meta package: ${META_PKG}"
echo "Output directory: ${OUT_DIR}"

apt-get update

pushd "${OUT_DIR}" >/dev/null
apt-get download "${META_PKG}"

# Resolve and download likely direct dependencies for the selected meta package.
# This intentionally keeps the script simple. A later image builder can use apt in a chroot
# when exact dependency closure is required.
apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts \
    --no-breaks --no-replaces --no-enhances "${META_PKG}" \
    | awk '/Depends: / {print $2}' \
    | grep -E '^(linux-image|linux-modules|linux-modules-extra|linux-base|linux-firmware)' \
    | sort -u \
    | xargs -r apt-get download
popd >/dev/null

echo "Downloaded kernel packages to ${OUT_DIR}"
