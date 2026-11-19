#
# Copyright (C) 2021-2023 KonstaKANG
# Copyright (C) 2025 Venkata Atchuta Bheemeswara Sarma Darbha
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit device configuration
CM5_DEVICE_PATH := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
CM5_COMMON_PATH := $(patsubst %/,%,$(dir $(CM5_DEVICE_PATH)))
$(call inherit-product, $(CM5_DEVICE_PATH)/device.mk)

PRODUCT_AAPT_CONFIG := normal mdpi hdpi
PRODUCT_AAPT_PREF_CONFIG := hdpi
PRODUCT_CHARACTERISTICS := tablet,nosdcard

$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
$(call enforce-product-packages-exist,com.android.ranging vendor_tracing_descriptors)

# Overlays
PRODUCT_PACKAGES += \
    AndroidOpiOverlay \
    SettingsProviderOpiOverlay \
    BluetoothOpiOverlay \
    SettingsOpiOverlay \
    WifiOpiOverlay \
    SystemUIOpiOverlay 

# Freeform windows
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.freeform_window_management.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.freeform_window_management.xml


# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/tablet_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/tablet_core_hardware.xml

# Device identifier. This must come after all inclusions.
PRODUCT_DEVICE := opi-cm5-tablet
PRODUCT_NAME := aosp_opi_cm5
PRODUCT_BRAND := OrangePi
PRODUCT_MODEL := Orange Pi CM5 Tablet
PRODUCT_MANUFACTURER := OrangePi

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.usb.config=adb

# Firmware reused from dvab-sarma's pinned Orange Pi vendor tree.
CM5_BRCM_FIRMWARE := vendor/opi/opi3b/proprietary/vendor/firmware/brcm
PRODUCT_COPY_FILES += \
    $(CM5_BRCM_FIRMWARE)/brcmfmac43456-sdio.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/brcm/brcmfmac43456-sdio.bin \
    $(CM5_BRCM_FIRMWARE)/brcmfmac43456-sdio.clm_blob:$(TARGET_COPY_OUT_VENDOR)/firmware/brcm/brcmfmac43456-sdio.clm_blob \
    $(CM5_DEVICE_PATH)/firmware/nvram_ap6256.txt:$(TARGET_COPY_OUT_VENDOR)/firmware/brcm/brcmfmac43456-sdio.xunlong,orangepi-cm5-tablet.txt \
    $(CM5_DEVICE_PATH)/firmware/regulatory.db:$(TARGET_COPY_OUT_VENDOR)/firmware/regulatory.db \
    $(CM5_DEVICE_PATH)/firmware/regulatory.db.p7s:$(TARGET_COPY_OUT_VENDOR)/firmware/regulatory.db.p7s

PRODUCT_COPY_FILES += \
    $(CM5_BRCM_FIRMWARE)/BCM4345C5.hcd:$(TARGET_COPY_OUT_VENDOR)/firmware/brcm/BCM4345C5.hcd
