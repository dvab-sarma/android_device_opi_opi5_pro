CM5_DEVICE_PATH := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
CM5_BOOT_FILES := $(CM5_DEVICE_PATH)/kernel/Image $(CM5_DEVICE_PATH)/kernel/rk3588s-orangepi-cm5-tablet.dtb $(CM5_DEVICE_PATH)/boot.scr $(CM5_DEVICE_PATH)/config.txt
$(INSTALLED_BOOTIMAGE_TARGET): $(INSTALLED_RAMDISK_TARGET) $(CM5_BOOT_FILES) $(CM5_DEVICE_PATH)/make_boot_image.sh
	$(hide) bash $(CM5_DEVICE_PATH)/make_boot_image.sh $(PRODUCT_OUT)/ramdisk.img $@
