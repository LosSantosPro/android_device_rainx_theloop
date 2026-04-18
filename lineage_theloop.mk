# 64-bit only zygote (32-bit crashes during preload)
ZYGOTE_FORCE_64 := true

# MindTheGapps (baklava/A16). WITH_GMS_VARIANT=core picks the YouTube+Play
# Store+Play-Integrity subset (gms_core.mk); =full inherits arm64-vendor.mk.
WITH_GMS ?= true
WITH_GMS_VARIANT ?= core

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product-if-exists, frameworks/base/data/sounds/AllAudio.mk)
$(call inherit-product, vendor/lineage/config/common.mk)

ifeq ($(WITH_GMS),true)
    ifeq ($(WITH_GMS_VARIANT),full)
        $(call inherit-product, vendor/gapps/arm64/arm64-vendor.mk)
    else
        $(call inherit-product, device/rainx/theloop/gms_core.mk)
    endif
endif

$(call inherit-product, device/rainx/theloop/device.mk)
$(call inherit-product, vendor/rainx/theloop/theloop-vendor.mk)

PRODUCT_NAME := lineage_theloop
PRODUCT_DEVICE := theloop
PRODUCT_BRAND := rainx
PRODUCT_MODEL := theloop
PRODUCT_MANUFACTURER := rainx
PRODUCT_PLATFORM := mt6877
