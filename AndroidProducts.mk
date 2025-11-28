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
