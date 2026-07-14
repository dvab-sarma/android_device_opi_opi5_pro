#
# Copyright (C) 2021-2023 KonstaKANG
# Copyright (C) 2025 Venkata Atchuta Bheemeswara Sarma Darbha
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit device configuration
$(call inherit-product, device/opi/opi5_pro/device.mk)

PRODUCT_AAPT_PREF_CONFIG := tvdpi
PRODUCT_CHARACTERISTICS := tv

$(call inherit-product, device/google/atv/products/atv_base.mk)
$(call enforce-product-packages-exist,com.android.ranging vendor_tracing_descriptors)

# Android TV
PRODUCT_PACKAGES += \
    DocumentsUI \
    LeanbackIME \
    TvProvision \
    TvSampleLeanbackLauncher \
    TvSettingsTwoPanel

# Bluetooth
PRODUCT_VENDOR_PROPERTIES += \
    bluetooth.device.class_of_device=34,4,36

# Boot animation
PRODUCT_COPY_FILES += \
    device/google/atv/products/bootanimations/bootanimation.zip:$(TARGET_COPY_OUT_SYSTEM)/media/bootanimation.zip

# Overlays
PRODUCT_PACKAGES += \
    AndroidTvOpiOverlay \
    BluetoothOpiOverlay \
    SettingsProviderTvOpiOverlay \
    WifiOpiOverlay

# Device identifier. This must come after all inclusions.
PRODUCT_DEVICE := opi5_pro
PRODUCT_NAME := aosp_opi
PRODUCT_BRAND := Orangepi
PRODUCT_MODEL := 5_pro
PRODUCT_MANUFACTURER := Orangepi
