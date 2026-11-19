#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail
source "$(dirname "$0")/scripts/common.sh"
cm5_source="${CM5_KERNEL_SOURCE:-$cm5_kernel_root/common}"
cm5_out="${CM5_KERNEL_OUT:-$cm5_android_top/out/cm5-kernel}"
[[ -f "$cm5_source/arch/arm64/configs/android_orangepicm5tablet_defconfig" ]] || { echo "Sync the companion kernel manifest first." >&2; exit 1; }
mkdir -p "$cm5_out" "$cm5_device/kernel"
args=(-C "$cm5_source" O="$cm5_out" ARCH=arm64 LLVM=1 HOSTCFLAGS="$cm5_host_cflags" HOSTLDFLAGS="$cm5_host_ldflags")
make "${args[@]}" android_orangepicm5tablet_defconfig
if [[ "${CM5_WIRINGOP_DEBUG:-1}" == 1 ]]; then
    "$cm5_source/scripts/kconfig/merge_config.sh" -m -O "$cm5_out" "$cm5_out/.config" "$cm5_source/arch/arm64/configs/wiringop_debug.config"
fi
make "${args[@]}" olddefconfig
make "${args[@]}" -j"$cm5_jobs" Image rockchip/rk3588s-orangepi-cm5-tablet.dtb
cp "$cm5_out/arch/arm64/boot/Image" "$cm5_device/kernel/"
cp "$cm5_out/arch/arm64/boot/dts/rockchip/rk3588s-orangepi-cm5-tablet.dtb" "$cm5_device/kernel/"
cp "$cm5_out/.config" "$cm5_device/kernel/kernel.config"
cp "$cm5_out/include/config/kernel.release" "$cm5_device/kernel/kernel.release"
(cd "$cm5_device/kernel" && sha256sum Image rk3588s-orangepi-cm5-tablet.dtb > SHA256SUMS.generated)
