#!/bin/bash
#
# Copyright (C) 2025 Venkata Atchuta Bheemeswara Sarma Darbha
# SPDX-License-Identifier: Apache-2.0
#
# Create an RK3588 GPT AOSP image (no changes to original sector/start/size values).
# - Writes U-Boot at sector 64
# - Creates GPT with named partitions so Android creates /dev/block/by-name/*
# - Copies boot/system/vendor images (dd)
# - Creates metadata/userdata ext4 and sets proper GPT & fs labels
# - Uses kpartx to map partitions and cleans up reliably
#
set -euo pipefail
IFS=$'\n\t'

# Helper: print error and cleanup
exit_with_error() {
  echo "ERROR: $*" >&2
  cleanup || true
  exit 1
}

cleanup() {

  if [ -n "${LOOPDEV:-}" ]; then
    if sudo kpartx -l "${IMAGE_PATH}" >/dev/null 2>&1; then
      sudo kpartx -d "${IMAGE_PATH}" || true
    fi
  fi
}

trap cleanup EXIT


: "${TARGET_PRODUCT:?TARGET_PRODUCT environment variable is not set. Run lunch first.}"
: "${ANDROID_PRODUCT_OUT:?ANDROID_PRODUCT_OUT environment variable is not set. Run lunch first.}"


for PART in boot system vendor; do
  if [ ! -f "${ANDROID_PRODUCT_OUT}/${PART}.img" ]; then
    exit_with_error "Missing partition image: ${ANDROID_PRODUCT_OUT}/${PART}.img — run 'make ${PART}image' first."
  fi
done

UBOOT_BIN=device/opi/opi5_pro-kernel/u-boot-rockchip.bin
if [ ! -f "${UBOOT_BIN}" ]; then
  exit_with_error "Missing U-Boot: ${UBOOT_BIN}"
fi

VERSION=OrangePi_5Pro_aosp
DATE=$(date +%Y%m%d)
TARGET=$(echo "${TARGET_PRODUCT}" | sed 's/^aosp_//')
IMGNAME=${VERSION}-${DATE}-${TARGET}_gpt.img
IMGSIZE=19456MiB
IMAGE_PATH="${ANDROID_PRODUCT_OUT}/${IMGNAME}"

if [ -f "${IMAGE_PATH}" ]; then
  exit_with_error "${IMAGE_PATH} already exists!"
fi

echo "Creating image file ${IMAGE_PATH} (${IMGSIZE})..."
sudo fallocate -l "${IMGSIZE}" "${IMAGE_PATH}"
sync

echo "Writing U-Boot to sector 64..."
# write u-boot binary to offset 64*512 = sector 64
sudo dd if="${UBOOT_BIN}" of="${IMAGE_PATH}" seek=64 bs=512 conv=notrunc status=progress
sync

echo "Partitioning image using sfdisk (GPT) with explicit partition NAMES..."


PART_TABLE=$(cat <<EOF
label: gpt
unit: sectors

# Partition 1: boot (FAT32)
${IMAGE_PATH}1 : start=32768, size=262144, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, name="boot"

# Partition 2: system (EXT4)
${IMAGE_PATH}2 : start=303104, size=6291456, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name="system"

# Partition 3: vendor (EXT4)
${IMAGE_PATH}3 : start=6596608, size=786432, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name="vendor"

# Partition 4: metadata (EXT4)
${IMAGE_PATH}4 : start=7385088, size=32768, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name="metadata"

# Partition 5: userdata (EXT4)
${IMAGE_PATH}5 : start=7417856, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name="userdata"
EOF
)

# Use a temporary file for sfdisk input so variable interpolation is safe
echo "${PART_TABLE}" | sudo sfdisk "${IMAGE_PATH}"
sync

echo "Mapping partitions using kpartx..."

KPARTX_OUT=$(sudo kpartx -av "${IMAGE_PATH}")
echo "${KPARTX_OUT}"

LOOPDEV=$(echo "${KPARTX_OUT}" | awk '/add map/ {dev=$3} END { sub(/p[0-9]+$/, "", dev); print dev }')
if [ -z "${LOOPDEV}" ]; then
  exit_with_error "kpartx failed to map partitions or to return a loop device name."
fi
echo "Mapped image as /dev/mapper/${LOOPDEV}p* (base loop: ${LOOPDEV})"

# Wait for device nodes to appear
sleep 1
if [ ! -b "/dev/mapper/${LOOPDEV}p1" ]; then
  echo "Waiting a bit longer for /dev/mapper/${LOOPDEV}p1 to appear..."
  sleep 1
fi
if [ ! -b "/dev/mapper/${LOOPDEV}p1" ]; then
  exit_with_error "Device mapper nodes not found (e.g. /dev/mapper/${LOOPDEV}p1). Check kpartx output."
fi

# --- Copy images into partitions ---
echo "Writing boot image to p1 (FAT partition)..."
sudo dd if="${ANDROID_PRODUCT_OUT}/boot.img" of="/dev/mapper/${LOOPDEV}p1" bs=1M conv=notrunc status=progress

echo "Writing system image to p2 (raw dd)."
# Use conv=notrunc so we don't shrink partition image area; status=progress for visibility
sudo dd if="${ANDROID_PRODUCT_OUT}/system.img" of="/dev/mapper/${LOOPDEV}p2" bs=1M conv=notrunc status=progress

echo "Writing vendor image to p3 (raw dd)."
sudo dd if="${ANDROID_PRODUCT_OUT}/vendor.img" of="/dev/mapper/${LOOPDEV}p3" bs=1M conv=notrunc status=progress

sync

# --- Ensure filesystem labels and types are correct ---
# Note: dd'ing system/vendor may already contain an internal FS label; we force the GPT
# partition name above and set the filesystem label to match as a guard.
echo "Setting filesystem labels on p2 (system) and p3 (vendor) and creating metadata/userdata..."

# Try to set ext4 label on system; if it isn't an ext4, warn but continue.
set +e
sudo e2label "/dev/mapper/${LOOPDEV}p2" system 2>/dev/null
E2_RC=$?
if [ "${E2_RC}" -ne 0 ]; then
  echo "Warning: /dev/mapper/${LOOPDEV}p2 does not appear to be ext4 or e2label failed. Continuing."
fi
sudo e2label "/dev/mapper/${LOOPDEV}p3" vendor 2>/dev/null || echo "Warning: e2label on vendor failed (maybe not ext4)."

set -e

# Create/format metadata and userdata partitions and set filesystem labels
sudo mkfs.ext4 -F -L metadata "/dev/mapper/${LOOPDEV}p4"
sudo mkfs.ext4 -F -L userdata "/dev/mapper/${LOOPDEV}p5"
sync

# Final sanity: list by-name symlinks
echo "Partition mapping summary (kpartx):"
sudo ls -l /dev/mapper/"${LOOPDEV}"* || true

# Unmap now that we have set labels
sudo kpartx -d "${IMAGE_PATH}" || true
# fix ownership
sudo chown "${USER}:${USER}" "${IMAGE_PATH}"

echo "✅ Created ${IMAGE_PATH} with GPT partition names and filesystem labels."
echo "You should now be able to write this image to your SD/NVMe and boot RK3588. "


sudo sgdisk -p "${IMAGE_PATH}"
exit 0
