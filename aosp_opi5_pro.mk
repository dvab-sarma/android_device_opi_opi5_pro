#
# Copyright (C) 2021-2023 KonstaKANG
# Copyright (C) 2025 Venkata Atchuta Bheemeswara Sarma Darbha
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit device configuration
$(call inherit-product, device/opi/opi5_pro/device.mk)

PRODUCT_AAPT_CONFIG := normal mdpi hdpi
PRODUCT_AAPT_PREF_CONFIG := hdpi
PRODUCT_CHARACTERISTICS := tablet,nosdcard

$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
$(call enforce-product-packages-exist,)

# Overlays
PRODUCT_PACKAGES += \
    AndroidOpiOverlay \
    SettingsProviderOpiOverlay \
    BluetoothOpiOverlay \
    SettingsOpiOverlay \
    WifiOpiOverlay \
    SystemUIOpiOverlay 

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/tablet_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/tablet_core_hardware.xml

# Device identifier. This must come after all inclusions.
PRODUCT_DEVICE := opi5_pro
PRODUCT_NAME := aosp_opi
PRODUCT_BRAND := Orangepi
PRODUCT_MODEL := 5_pro
PRODUCT_MANUFACTURER := Orangepi
