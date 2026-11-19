#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail
source "$(dirname "$0")/scripts/common.sh"
cm5_source="${CM5_UBOOT_SOURCE:-$cm5_kernel_root/u-boot}"
cm5_out="${CM5_UBOOT_OUT:-$cm5_android_top/out/cm5-uboot}"
patch="$cm5_device/patches/u-boot/0001-cm5-tablet.patch"
if git -C "$cm5_source" apply --reverse --check "$patch" 2>/dev/null; then
    echo "CM5 U-Boot patch is already applied."
else
    git -C "$cm5_source" apply --check "$patch"
    git -C "$cm5_source" apply "$patch"
fi
[[ -n "${BL31:-}" && -s "$BL31" && -n "${ROCKCHIP_TPL:-}" && -s "$ROCKCHIP_TPL" ]] || {
    echo "Set BL31 and ROCKCHIP_TPL to the documented Rockchip firmware files." >&2; exit 1;
}
export BL31 ROCKCHIP_TPL
export PATH="$cm5_kernel_root/prebuilts/clang/host/linux-x86/clang-r584948c/bin:$PATH"
if [[ -d "$cm5_kernel_root/prebuilts/kernel-build-tools/linux_musl-x86/share/swig" ]]; then
    export SWIG_LIB="$cm5_kernel_root/prebuilts/kernel-build-tools/linux_musl-x86/share/swig"
fi
mkdir -p "$cm5_out" "$cm5_device/kernel"
make -C "$cm5_source" O="$cm5_out" orangepi-cm5-tablet-rk3588s_defconfig
make -C "$cm5_source" O="$cm5_out" -j"$cm5_jobs" HOSTCFLAGS="$cm5_host_cflags" HOSTLDFLAGS="$cm5_host_ldflags" \
    CROSS_COMPILE=aarch64-linux-gnu- CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm \
    OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf
cp "$cm5_out/u-boot-rockchip.bin" "$cm5_device/kernel/"
"$cm5_out/tools/mkimage" -A arm64 -O linux -T script -C none -n 'Orange Pi CM5 boot' \
    -d "$cm5_device/boot.cmd" "$cm5_device/boot.scr"
