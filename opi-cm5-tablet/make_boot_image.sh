#!/usr/bin/env bash
set -euo pipefail
src="$(cd "$(dirname "$0")" && pwd)"
cm5_boot_kernel="${CM5_BOOT_KERNEL_DIR:-$src/kernel}"
ramdisk="${1:?usage: make_boot_image.sh ramdisk.img boot.img}"
output="${2:?usage: make_boot_image.sh ramdisk.img boot.img}"
for f in "$ramdisk" "$cm5_boot_kernel/Image" "$cm5_boot_kernel/rk3588s-orangepi-cm5-tablet.dtb" "$src/boot.scr" "$src/config.txt"; do
    test -s "$f" || { echo "Missing boot input: $f" >&2; exit 1; }
done
mkdir -p "$(dirname "$output")"
tmp="$(mktemp "${output}.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
truncate -s 128M "$tmp"
mkfs.fat -F 32 -n boot "$tmp"
mcopy -i "$tmp" "$cm5_boot_kernel/Image" "$cm5_boot_kernel/rk3588s-orangepi-cm5-tablet.dtb" "$src/boot.scr" "$src/config.txt" ::/
mcopy -i "$tmp" "$ramdisk" ::/ramdisk.img
mv "$tmp" "$output"
