#
# Copyright (C) 2025 Venkata Atchuta Bheemeswara Sarma Darbha
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/opi/opi5_pro
PRODUCT_SOONG_NAMESPACES += $(DEVICE_PATH)

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, frameworks/native/build/tablet-7in-xhdpi-2048-dalvik-heap.mk)
$(call inherit-product, vendor/opi/opi3b/opi3b-vendor.mk)

# APEX
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# API level
PRODUCT_SHIPPING_API_LEVEL := 35

# Audio
PRODUCT_PACKAGES += \
    android.hardware.audio.service \
    android.hardware.audio@7.1-impl \
    android.hardware.audio.effect@7.0-impl \
    audio.r_submix.default \
    audio.usb.default \
    audio.primary.opi \
    audio.primary.opi_hdmi

PRODUCT_PACKAGES += \
    tinycap \
    tinyhostless \
    tinymix \
    tinypcminfo \
    tinyplay


PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    frameworks/av/media/libeffects/data/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml




PRODUCT_COPY_FILES += \
    external/alsa-lib/src/conf/alsa.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/alsa.conf \
    external/alsa-lib/src/conf/cards/aliases.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/cards/aliases.conf \
    external/alsa-lib/src/conf/cards/vc4-hdmi.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/cards/vc4-hdmi.conf \
    external/alsa-lib/src/conf/ctl/default.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/ctl/default.conf \
    external/alsa-lib/src/conf/pcm/center_lfe.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/center_lfe.conf \
    external/alsa-lib/src/conf/pcm/default.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/default.conf \
    external/alsa-lib/src/conf/pcm/dmix.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/dmix.conf \
    external/alsa-lib/src/conf/pcm/dpl.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/dpl.conf \
    external/alsa-lib/src/conf/pcm/dsnoop.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/dsnoop.conf \
    external/alsa-lib/src/conf/pcm/front.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/front.conf \
    external/alsa-lib/src/conf/pcm/hdmi.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/hdmi.conf \
    external/alsa-lib/src/conf/pcm/iec958.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/iec958.conf \
    external/alsa-lib/src/conf/pcm/modem.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/modem.conf \
    external/alsa-lib/src/conf/pcm/rear.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/rear.conf \
    external/alsa-lib/src/conf/pcm/side.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/side.conf \
    external/alsa-lib/src/conf/pcm/surround21.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/surround21.conf \
    external/alsa-lib/src/conf/pcm/surround40.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/surround40.conf \
    external/alsa-lib/src/conf/pcm/surround41.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/surround41.conf \
    external/alsa-lib/src/conf/pcm/surround50.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/surround50.conf \
    external/alsa-lib/src/conf/pcm/surround51.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/surround51.conf \
    external/alsa-lib/src/conf/pcm/surround71.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/pcm/surround71.conf \
    external/alsa-lib/src/conf/smixer.conf:$(TARGET_COPY_OUT_VENDOR)/etc/alsa/smixer.conf

# Bluetooth
PRODUCT_PACKAGES += \
    com.android.hardware.bluetooth.opi5

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml

PRODUCT_PACKAGES += \
    android.hardware.bluetooth.audio-impl \
    audio.bluetooth.default

PRODUCT_COPY_FILES += \
    frameworks/av/services/audiopolicy/config/a2dp_in_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_in_audio_policy_configuration_7_0.xml \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration_7_0.xml


# !-----TODO : Camera isn't supported currently and might be implemented in the near future. Kept just in case.
# # Camera
# PRODUCT_PACKAGES += \
#     android.hardware.camera.provider-V1-external-service

# PRODUCT_COPY_FILES += \
#     $(DEVICE_PATH)/camera/external_camera_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml

# PRODUCT_COPY_FILES += \
#     frameworks/native/data/etc/android.hardware.camera.external.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.external.xml

# PRODUCT_PACKAGES += \
#     android.hardware.camera.provider@2.5-service_64
# #     camera.libcamera \
# #     ipa_rpi_pisp

# PRODUCT_COPY_FILES += \
#     $(DEVICE_PATH)/camera/android.hardware.camera.provider@2.5-service_64.opi.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/android.hardware.camera.provider@2.5-service_64.opi.rc

# # PRODUCT_COPY_FILES += \
# #     $(DEVICE_PATH)/camera/camera_hal.yaml:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/camera_hal.yaml \
# #     external/libcamera/src/ipa/rpi/pisp/data/imx219.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/imx219.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/imx219_noir.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/imx219_noir.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/imx296.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/imx296.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/imx296_mono.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/imx296_mono.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/imx477.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/imx477.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/imx477_noir.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/imx477_noir.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/imx477_scientific.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/imx477_scientific.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/imx500.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/imx500.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/imx519.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/imx519.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/imx708.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/imx708.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/imx708_noir.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/imx708_noir.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/imx708_wide.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/imx708_wide.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/imx708_wide_noir.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/imx708_wide_noir.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/ov5647.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/ov5647.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/ov5647_noir.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/ov5647_noir.json \
# #     external/libcamera/src/ipa/rpi/pisp/data/ov64a40.json:$(TARGET_COPY_OUT_VENDOR)/etc/libcamera/ipa/rpi/pisp/ov64a40.json

# PRODUCT_COPY_FILES += \
#     frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml \
#     frameworks/native/data/etc/android.hardware.camera.concurrent.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.concurrent.xml \
#     frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
#     frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
#     frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.full.xml \
#     frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.raw.xml

# PRODUCT_COPY_FILES += \
#     $(DEVICE_PATH)/camera/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml

# # CEC
# PRODUCT_PACKAGES += \
#     com.android.hardware.tv.hdmi.cec.opi5 \
#     com.android.hardware.tv.hdmi.connection.opi5

# PRODUCT_COPY_FILES += \
#     frameworks/native/data/etc/android.hardware.hdmi.cec.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.hdmi.cec.xml

#cec
PRODUCT_PACKAGES += \
    com.android.hardware.tv.hdmi.connection.opi5

# Debugfs
PRODUCT_SET_DEBUGFS_RESTRICTIONS := false

# DRM
PRODUCT_PACKAGES += \
    com.android.hardware.drm.clearkey

# Emergency info
PRODUCT_PACKAGES += \
    EmergencyInfo

# Ethernet
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml

#FFmpeg
PRODUCT_PACKAGES += \
    com.android.hardware.media.c2.ffmpeg



PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/media/media_codecs_ffmpeg_c2.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_ffmpeg_c2.xml \
    $(DEVICE_PATH)/seccomp_policy/android.hardware.media.c2-ffmpeg.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/android.hardware.media.c2-ffmpeg.policy

# Gatekeeper
PRODUCT_PACKAGES += \
    com.android.hardware.gatekeeper.nonsecure

# Graphics
ifeq ($(BOARD_USES_ANGLE),true)
TARGET_USES_VULKAN := true

$(call soong_config_set, minigbm, platform, rockchip)

PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator-service.minigbm \
    mapper.minigbm \
    gralloc.minigbm
 
PRODUCT_PACKAGES += \
    libEGL_angle \
    libGLESv1_CM_angle \
    libGLESv2_angle

PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware.vulkan=panfrost \
    ro.hardware.egl=angle \
    ro.opengles.version=196610 \
    debug.renderengine.backend=skiavkthreaded


PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware.gralloc=minigbm

# ! --------- WARNING : This dependency is currently under developement and if used might cause rendering problems and potential mishaps
# PRODUCT_PACKAGES += \
#     mesa3d_desktop-panvk_libvulkan_panfrost
    

else

PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator-service.minigbm_gbm_mesa \
    mapper.minigbm_gbm_mesa \
    libgbm_mesa_wrapper \

PRODUCT_PACKAGES += \
    libEGL_mesa \
    libGLESv1_CM_mesa \
    libGLESv2_mesa \
    libgallium_dri

PRODUCT_PACKAGES += \
    dri_gbm \
    libgbm_mesa

PRODUCT_PACKAGES += \
    vulkan.panfrost

PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware.egl=mesa

endif

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2024-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml



PRODUCT_PACKAGES += \
    com.android.hardware.graphics.composer.drm_hwcomposer
    
    

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2024-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml

# Health
PRODUCT_PACKAGES += \
    com.android.hardware.health.opi5

# HIDL
PRODUCT_PACKAGES += \
    android.hidl.allocator@1.0-service \
    hwservicemanager

# Kernel
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)-kernel/Image:$(PRODUCT_OUT)/kernel

# Keylayout
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/keylayout/Generic.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/Generic.kl

# Keymint
PRODUCT_PACKAGES += \
    com.android.hardware.keymint.rust_nonsecure

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.keystore.app_attest_key.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.keystore.app_attest_key.xml

 # Lights
 PRODUCT_PACKAGES += \
    com.android.hardware.light.opi5

# Media
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/media/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_tv.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_tv.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_video.xml

# Power
PRODUCT_PACKAGES += \
    com.android.hardware.power

# Ramdisk
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/ramdisk/fstab.opi5:$(TARGET_COPY_OUT_RAMDISK)/fstab.opi5 \
    $(DEVICE_PATH)/ramdisk/fstab.opi5:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.opi5 \
    $(DEVICE_PATH)/ramdisk/init.opi5.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.opi5.rc \
    $(DEVICE_PATH)/ramdisk/init.opi5.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.opi5.usb.rc \
    $(DEVICE_PATH)/ramdisk/ueventd.opi5.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

# Seccomp
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/seccomp_policy/mediacodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediacodec.policy \
    $(DEVICE_PATH)/seccomp_policy/mediaswcodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediaswcodec.policy

# Storage
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

 # Suspend
 PRODUCT_PACKAGES += \
     com.android.hardware.suspend_blocker.opi5

# Thermal
PRODUCT_PACKAGES += \
    com.android.hardware.thermal

# Touchscreen
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml


# USB
PRODUCT_PACKAGES += \
    com.android.hardware.usb \
    com.android.hardware.usb.gadget.opi5

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

# Virtualization
$(call inherit-product, packages/modules/Virtualization/apex/product_packages.mk)



# Wifi
PRODUCT_PACKAGES += \
    android.hardware.wifi-service \
    hostapd \
    hostapd_cli \
    libwpa_client \
    wificond \
    wpa_cli \
    wpa_supplicant \
    wpa_supplicant.conf

PRODUCT_COPY_FILES += \
    hardware/broadcom/wlan/bcmdhd/config/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml

# Window extensions
$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)
