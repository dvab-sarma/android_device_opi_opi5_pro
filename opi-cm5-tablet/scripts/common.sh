#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
cm5_device="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cm5_android_top="${ANDROID_BUILD_TOP:-${CM5_ANDROID_TOP:-}}"
if [[ -z "$cm5_android_top" ]]; then
    cm5_android_top="$cm5_device"
    while [[ ! -f "$cm5_android_top/build/envsetup.sh" && "$cm5_android_top" != / ]]; do
        cm5_android_top="$(dirname "$cm5_android_top")"
    done
fi
[[ -f "$cm5_android_top/build/envsetup.sh" ]] || { echo "Set ANDROID_BUILD_TOP to your Android checkout." >&2; exit 1; }
cm5_kernel_root="${CM5_KERNEL_ROOT:-$(dirname "$cm5_android_top")/cm5-kernel}"
cm5_jobs="${JOBS:-$(nproc)}"
cm5_host_cflags="-O2"
cm5_host_ldflags=""
if [[ -n "${CM5_HOST_PREFIX:-}" ]]; then
    cm5_host_cflags+=" -I$CM5_HOST_PREFIX/usr/include -I$CM5_HOST_PREFIX/usr/include/$(gcc -dumpmachine)"
    cm5_host_ldflags="-L$CM5_HOST_PREFIX/usr/lib/$(gcc -dumpmachine) -Wl,-rpath,$CM5_HOST_PREFIX/usr/lib/$(gcc -dumpmachine)"
fi
export PATH="$cm5_kernel_root/prebuilts/clang/host/linux-x86/clang-r596125/bin:$cm5_kernel_root/prebuilts/kernel-build-tools/linux_musl-x86/bin:$cm5_android_top/prebuilts/build-tools/linux-x86/bin:$PATH"
