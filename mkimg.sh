
#
# Copyright (C) 2025 Venkata Atchuta Bheemeswara Sarma Darbha
#
# SPDX-License-Identifier: Apache-2.0
#
#!/bin/bash

exit_with_error() {
  echo $@
  exit 1
}

# Check required env vars
if [ -z ${TARGET_PRODUCT} ]; then
  exit_with_error "TARGET_PRODUCT environment variable is not set. Run lunch first."
fi

if [ -z ${ANDROID_PRODUCT_OUT} ]; then
  exit_with_error "ANDROID_PRODUCT_OUT environment variable is not set. Run lunch first."
fi

# Check required images
for PARTITION in "boot" "system" "vendor"; do
  if [ ! -f ${ANDROID_PRODUCT_OUT}/${PARTITION}.img ]; then
    exit_with_error "Partition image not found: ${PARTITION}.img. Run 'make ${PARTITION}image' first."
  fi
done

UBOOT_BIN=device/opi/opi5_pro-kernel/u-boot-rockchip.bin

if [ ! -f ${UBOOT_BIN} ]; then
  exit_with_error "Missing u-boot-rockchip.bin! Make sure it's built and placed at ${UBOOT_BIN}"
fi

VERSION=OrangePi_5Pro_aosp
DATE=$(date +%Y%m%d)
TARGET=$(echo ${TARGET_PRODUCT} | sed 's/^aosp_//')
IMGNAME=${VERSION}-${DATE}-${TARGET}.img
IMGSIZE=16384MiB

if [ -f ${ANDROID_PRODUCT_OUT}/${IMGNAME} ]; then
  exit_with_error "${ANDROID_PRODUCT_OUT}/${IMGNAME} already exists!"
fi

echo "Creating image file ${ANDROID_PRODUCT_OUT}/${IMGNAME}..."
sudo fallocate -l ${IMGSIZE} ${ANDROID_PRODUCT_OUT}/${IMGNAME}
sync

echo "Writing U-Boot to sector 64..."
sudo dd if=${UBOOT_BIN} of=${ANDROID_PRODUCT_OUT}/${IMGNAME} seek=64 bs=512 conv=notrunc
sync

echo "Partitioning image using sfdisk..."
PART_TABLE=$(cat <<EOF
label: dos
unit: sectors

${ANDROID_PRODUCT_OUT}/${IMGNAME}1 : start=32768, size=262144, type=c, bootable
${ANDROID_PRODUCT_OUT}/${IMGNAME}2 : start=294912, size=5242880, type=83
${ANDROID_PRODUCT_OUT}/${IMGNAME}3 : start=5617792, size=524288, type=83
${ANDROID_PRODUCT_OUT}/${IMGNAME}4 : start=6142080, type=83
EOF
)

echo "$PART_TABLE" | sudo sfdisk ${ANDROID_PRODUCT_OUT}/${IMGNAME}
sync

LOOPDEV=$(sudo kpartx -av ${ANDROID_PRODUCT_OUT}/${IMGNAME} | awk 'NR==1{ sub(/p[0-9]$/, "", $3); print $3 }')
if [ -z ${LOOPDEV} ]; then
  exit_with_error "Unable to find loop device!"
fi
echo "Image mounted as /dev/${LOOPDEV}"
sleep 1

echo "Copying boot..."
sudo dd if=${ANDROID_PRODUCT_OUT}/boot.img of=/dev/mapper/${LOOPDEV}p1 bs=1M
echo "Copying system..."
sudo dd if=${ANDROID_PRODUCT_OUT}/system.img of=/dev/mapper/${LOOPDEV}p2 bs=1M
echo "Copying vendor..."
sudo dd if=${ANDROID_PRODUCT_OUT}/vendor.img of=/dev/mapper/${LOOPDEV}p3 bs=1M

echo "Creating userdata..."
sudo mkfs.ext4 /dev/mapper/${LOOPDEV}p4 -I 512 -L userdata
# sudo mkdir -p /mnt/tmp_userdata
# sudo mount /dev/mapper/${LOOPDEV}p4 /mnt/tmp_userdata
# sudo mkdir -p /mnt/tmp_userdata/misc/keystore
# sudo mkdir -p /mnt/tmp_userdata/apex/sessions
# sudo umount /mnt/tmp_userdata
sync

sudo kpartx -d "/dev/${LOOPDEV}"
sudo chown ${USER}:${USER} ${ANDROID_PRODUCT_OUT}/${IMGNAME}

echo "✅ Done! Created ${ANDROID_PRODUCT_OUT}/${IMGNAME} with U-Boot and properly aligned partitions."
exit 0