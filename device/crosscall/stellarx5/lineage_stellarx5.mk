#
# SPDX-License-Identifier: Apache-2.0
#

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
TARGET_SUPPORTS_OMX_SERVICE := false
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

$(call inherit-product, device/crosscall/stellarx5/device.mk)

$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_stellarx5
PRODUCT_DEVICE := stellarx5
PRODUCT_MANUFACTURER := Crosscall
PRODUCT_BRAND := Crosscall
PRODUCT_MODEL := Stellar X5

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="StellarX5-user 15 AP1A.240505.004 release-keys" \
    BuildFingerprint=Crosscall/StellarX5/stellarx5:15/AP1A.240505.004/release-keys \
    DeviceName=stellarx5 \
    DeviceProduct=stellarx5 \
    SystemDevice=stellarx5 \
    SystemName=stellarx5
