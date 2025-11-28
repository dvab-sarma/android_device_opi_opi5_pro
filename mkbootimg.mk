#
# Copyright (C) 2021-2022 KonstaKANG
# Copyright (C) 2025 Venkata Atchuta Bheemeswara Sarma Darbha
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/opi/opi5_pro
KERNEL_PATH := device/opi/opi5_pro-kernel

OPI_BOOT_OUT := $(PRODUCT_OUT)/opiboot
$(OPI_BOOT_OUT): $(INSTALLED_RAMDISK_TARGET)
	mkdir -p $(OPI_BOOT_OUT)
	cp $(KERNEL_PATH)/Image $(OPI_BOOT_OUT)
	cp $(KERNEL_PATH)/rk3588s-orangepi-5-pro-1.dtb $(OPI_BOOT_OUT)
	cp $(KERNEL_PATH)/rk3588-orangepi-5-max.dtb $(OPI_BOOT_OUT)
	cp $(KERNEL_PATH)/rk3588-orangepi-5-plus.dtb $(OPI_BOOT_OUT)
	cp $(KERNEL_PATH)/rk3588-orangepi-5-ultra.dtb $(OPI_BOOT_OUT)
	cp $(KERNEL_PATH)/rk3588s-orangepi-5.dtb $(OPI_BOOT_OUT)
	cp $(KERNEL_PATH)/rk3588s-orangepi-5b.dtb $(OPI_BOOT_OUT)
	cp $(KERNEL_PATH)/android-sdcard.dtbo $(OPI_BOOT_OUT)
	cp $(KERNEL_PATH)/boot.scr $(OPI_BOOT_OUT)
	cp $(KERNEL_PATH)/uRamdisk $(OPI_BOOT_OUT)
	cp $(KERNEL_PATH)/uRecovery $(OPI_BOOT_OUT)
	cp $(PRODUCT_OUT)/ramdisk.img $(OPI_BOOT_OUT)
	cp $(KERNEL_PATH)/config.txt $(OPI_BOOT_OUT)


$(INSTALLED_BOOTIMAGE_TARGET): $(OPI_BOOT_OUT)
	$(call pretty,"Target boot image: $@")

	# Determine size in bytes, add 10 MiB padding, convert to 512-byte blocks
	BOOT_SIZE_BYTES=`du -s -k $(OPI_BOOT_OUT) | awk '{ print $$1 * 1024 }'`; \
	PADDED_BYTES=`expr $$BOOT_SIZE_BYTES + 10485760`; \
	BLOCKS=`expr $$PADDED_BYTES / 512`; \
	echo "Creating boot image with $$BLOCKS blocks..."; \
	dd if=/dev/zero of=$@ bs=512 count=$$BLOCKS; \
	mkfs.fat -F 32 -n "boot" $@; \
	mcopy -s -i $@ $(OPI_BOOT_OUT)/* ::


