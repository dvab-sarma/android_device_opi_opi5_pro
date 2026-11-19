#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
set -eo pipefail
source "$(dirname "$0")/scripts/common.sh"
"$cm5_device/build_kernel.sh"
"$cm5_device/build_bootloader.sh"
cd "$cm5_android_top"
source build/envsetup.sh
lunch aosp_opi_cm5-cp2a-userdebug
m -j"$cm5_jobs"
python3 "$cm5_device/make_image.py" "$ANDROID_PRODUCT_OUT" "$@"
