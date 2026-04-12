# Inherit from those products. Most specific first.
# 64-bit only zygote (32-bit crashes during preload)
ZYGOTE_FORCE_64 := true

# Explicitly opt out of GMS. For GApps, use WITH_GMS=true at lunch time.
WITH_GMS := false
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
# AOSP audio assets - full_base_telephony.mk ships none
$(call inherit-product-if-exists, frameworks/base/data/sounds/AllAudio.mk)
# LineageOS common config
$(call inherit-product, vendor/lineage/config/common.mk)
# Device config
$(call inherit-product, device/rainx/theloop/device.mk)
# Vendor blobs
$(call inherit-product, vendor/rainx/theloop/theloop-vendor.mk)
# Product Info
PRODUCT_NAME := lineage_theloop
PRODUCT_DEVICE := theloop
PRODUCT_BRAND := rainx
PRODUCT_MODEL := theloop
PRODUCT_MANUFACTURER := rainx
# Platform
PRODUCT_PLATFORM := mt6877
