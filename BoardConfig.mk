DEVICE_PATH := device/rainx/theloop
# 1. ARCHITECTURE
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic
TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_BOARD_PLATFORM := mt6877
TARGET_BOOTLOADER_BOARD_NAME := mt6877
# 2. KERNEL
TARGET_NO_KERNEL := false
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilts/Image.gz
BOARD_KERNEL_IMAGE_NAME := Image.gz
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilts/dtb.img
BOARD_KERNEL_SEPARATED_DTBO := true
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilts/dtbo.img
BOARD_USES_GENERIC_KERNEL_IMAGE := false
# Kernel command line
# console=ttyS0 removed - triggered SystemUI serial console notification
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 firmware_class.path=/vendor/firmware
# SELinux enforcing (default)
# androidboot.debuggable / androidboot.secure removed - build variant sets these
BOARD_KERNEL_CMDLINE += androidboot.tee_type=2
BOARD_KERNEL_CMDLINE += androidboot.usbcontroller=11201000.usb0
BOARD_BOOTCONFIG :=
# 3. BOOT HEADERS
BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_BASE := 0x40078000
BOARD_RAMDISK_OFFSET := 0x11088000
BOARD_KERNEL_TAGS_OFFSET := 0x07c08000
BOARD_DTB_OFFSET := 0x07c08000
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION) --base $(BOARD_KERNEL_BASE) --pagesize $(BOARD_KERNEL_PAGESIZE)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET) --dtb $(TARGET_PREBUILT_DTB)
BOARD_VENDOR_BOOTIMAGE_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION) --base $(BOARD_KERNEL_BASE) --pagesize $(BOARD_KERNEL_PAGESIZE)
BOARD_VENDOR_BOOTIMAGE_ARGS += --vendor_ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_VENDOR_BOOTIMAGE_ARGS += --dtb_offset $(BOARD_DTB_OFFSET) --dtb $(TARGET_PREBUILT_DTB)
# 4. PARTITIONS
# Patched manifest with camera.provider HAL block removed
DEVICE_MANIFEST_FILE := device/rainx/theloop/vintf/manifest-nocam.xml
DEVICE_MANIFEST_FILE += device/rainx/theloop/vintf/android.hardware.audio.service-aidl.mediatek.xml
# WiFi VINTF: device-level @2 declaration required; Soong overrides on
# vendor prebuilt suppress the AOSP module and its auto-generated @3 fragment.
DEVICE_MANIFEST_FILE += device/rainx/theloop/vintf/android.hardware.wifi-service-lazy.xml
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 68157440
# Dynamic / super partition (matches stock lpdump)
BOARD_SUPER_PARTITION_SIZE := 9663676416
BOARD_SUPER_PARTITION_GROUPS := main
BOARD_MAIN_SIZE := 9661579264
BOARD_MAIN_PARTITION_LIST := \
    system \
    system_ext \
    product \
    vendor \
    vendor_dlkm \
    system_dlkm \
    odm_dlkm
# Copy-out mount points
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm
TARGET_COPY_OUT_ODM_DLKM := odm_dlkm
# Filesystems - erofs (matches stock)
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
# Virtual A/B
BOARD_VIRTUAL_AB_ENABLE := true
BOARD_USES_SNAPUSERD := true
# 5. RAMDISK CONFIG
BOARD_USES_VENDOR_BOOTIMAGE := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
BOARD_RAMDISK_USE_LZ4 := true
BOARD_RAMDISK_COMPRESSION := lz4
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.mt6877
# Recovery touch - handled via prebuilts/modules/ + init.recovery.mt6877.rc.
# Touch .ko files (focaltech, sitronix) staged to vendor_ramdisk via wildcard
# but NOT in modules.load; first-stage init skips them. Loading driven by
# explicit insmod in init.recovery.mt6877.rc on boot (after base module deps).
# BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES is not a real build variable;
# only BOARD_VENDOR_RAMDISK_KERNEL_MODULES + _LOAD are recognized.
# 6. INIT & MISC
BOARD_USES_INIT_BOOT_IMAGE := true
BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)
BOARD_ROOT_EXTRA_FOLDERS := metadata vendor acct
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
# FMRadio requires libfmjni but the vendor prebuilt (prefer:true) renames it
# to prebuilt_libfmjni in Make, breaking the dep. Prebuilt installs correctly.
BUILD_BROKEN_MISSING_REQUIRED_MODULES := true
# TARGET_VNDK_USE_CORE_VARIANT removed - VNDK deprecated in A16.
BOARD_SECCOMP_POLICY += $(DEVICE_PATH)/seccomp_policy

# LineageOS Health HAL - charging control via MT6360 input_current_limit
$(call soong_config_set,lineage_health,charging_control_charging_path,/sys/class/power_supply/mtk-master-charger/input_current_limit)
$(call soong_config_set,lineage_health,charging_control_charging_enabled,500000)
$(call soong_config_set,lineage_health,charging_control_charging_disabled,0)
# AVB (chained vbmeta)
BOARD_AVB_ENABLE := true
# Top-level vbmeta
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_ROLLBACK_INDEX := 0
BOARD_AVB_ROLLBACK_INDEX_LOCATION := 0
# Chained vbmeta_system.img
BOARD_AVB_VBMETA_SYSTEM := system system_ext product system_dlkm
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 1
BOARD_AVB_VBMETA_SYSTEM_ARGS += --flags 3
# Chained vbmeta_vendor.img
BOARD_AVB_VBMETA_VENDOR := vendor vendor_dlkm odm_dlkm
BOARD_AVB_VBMETA_VENDOR_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_VENDOR_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX := 0
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX_LOCATION := 2
BOARD_AVB_VBMETA_VENDOR_ARGS += --flags 3
# UI Tweaks
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_DENSITY := xhdpi
TARGET_RECOVERY_UI_MARGIN_HEIGHT := 80
TARGET_RECOVERY_UI_MARGIN_WIDTH := 80
# BUILD_BROKEN_VINTF_COMPATIBILITY_MATRIX removed - not in A16 allowed list.
# Vendor BoardConfig
-include vendor/rainx/theloop/BoardConfigVendor.mk
SKIP_ABI_CHECKS := true

# SEPolicy
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
# Stock file_contexts auto-import. Ships after sepolicy/vendor;
# file_contexts_bin uses last-match-wins, so lineage overrides go
# in sepolicy/vendor/file_contexts. See vendor_mtk_prebuilt/HEADER.txt.
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor_mtk_prebuilt
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private

# pq_aidl and all other vendor HALs are already in the stock manifest.xml

# Vendor SPL pinned to stock blob patch level. Empty value breaks VINTF
# check and Settings display. Bump only when resyncing blobs from newer OTA.
VENDOR_SECURITY_PATCH := 2025-12-05

# TODO: enable VINTF enforcement for A16. Currently breaks the build
# because proprietary manifest HAL versions don't match framework matrix.
# TARGET_ENFORCE_VINTF_MANIFEST := true
