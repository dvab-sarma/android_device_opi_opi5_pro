#
# Copyright (C) 2021-2023 KonstaKANG
# Copyright (C) 2025 Venkata Atchuta Bheemeswara Sarma Darbha
#
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/aosp_opi5_pro.mk \
    $(LOCAL_DIR)/aosp_opi5_pro_car.mk \
    $(LOCAL_DIR)/aosp_opi5_pro_tv.mk

COMMON_LUNCH_CHOICES := \
    aosp_opi5_pro-trunk_staging-userdebug \
    aosp_opi5_pro_car-trunk_staging-userdebug \
    aosp_opi5_pro_tv-trunk_staging-userdebug

# Independent CM5 tablet product; the 5 Pro product remains unchanged.
PRODUCT_MAKEFILES += $(LOCAL_DIR)/opi-cm5-tablet/aosp_opi_cm5.mk
COMMON_LUNCH_CHOICES += aosp_opi_cm5-cp2a-userdebug
