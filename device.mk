DEVICE_PATH := device/rainx/theloop
DEVICE_PACKAGE_OVERLAYS += $(DEVICE_PATH)/overlay

# MTK framework JARs on BOOTCLASSPATH (system_ext partition).
# Required for MTK system APKs that import com.mediatek.* classes.
# dex_import alone only stages files; BOOTCLASSPATH entry is needed
# for classloading. All eight stock JARs in stock order; partial
# sets fail dex2oat verification due to cross-jar symbol deps.
# system_ext: prefix required - platform boot jars break hiddenapi scan.
# A16: device-specific JARs must use PRODUCT_BOOT_JARS_EXTRA.
PRODUCT_BOOT_JARS_EXTRA += \
    system_ext:mediatek-telephony-base \
    system_ext:mediatek-telephony-common \
    system_ext:mediatek-carrier-config-manager \
    system_ext:mediatek-common \
    system_ext:mediatek-framework \
    system_ext:mediatek-ims-common \
    system_ext:mediatek-ims-base \
    system_ext:mediatek-telecom-common

PRODUCT_USE_DYNAMIC_PARTITIONS := true
# PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE removed - always true in A16.
# PRODUCT_TARGET_VNDK_VERSION removed - VNDK deprecated in A16.
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(DEVICE_PATH)/compatibility_matrix.xml
# OTA SUPPORT
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    init_boot \
    vendor_boot \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    system \
    system_ext \
    product \
    vendor \
    vendor_dlkm \
    system_dlkm \
    odm_dlkm
# Ensure DLKM partitions are built
PRODUCT_BUILD_VENDOR_DLKM_IMAGE := true
PRODUCT_BUILD_SYSTEM_DLKM_IMAGE := true
PRODUCT_BUILD_ODM_DLKM_IMAGE := true
# PACKAGES
PRODUCT_PACKAGES += \
    fastbootd \
    update_engine_sideload \
    snapuserd \
    e2fsck_ramdisk \
    tune2fs_ramdisk \
    resize2fs_ramdisk \
    fsck.f2fs_ramdisk \
    android.hardware.boot@1.2-impl \
    android.hardware.boot@1.2-impl.recovery \
    bootctrl.default \
    bootctrl.default.recovery \
    fs_config_dirs \
    fs_config_files \
    android.hardware.security.keymint-service \
    android.hardware.wifi-service-lazy.rainx \
# ROOT COPY
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/recovery/root,recovery/root)
# CRITICAL BOOT FILES
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/etc/ueventd.mt6877.rc:vendor_ramdisk/ueventd.mt6877.rc \
    $(DEVICE_PATH)/rootdir/etc/init.mt6877.rc:vendor_ramdisk/init.mt6877.rc \
    $(DEVICE_PATH)/rootdir/etc/init.mt6877.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.mt6877.rc \
    $(DEVICE_PATH)/rootdir/etc/init.keymint_override.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.keymint_override.rc \
    $(DEVICE_PATH)/rootdir/etc/init.sysext_override.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.sysext_override.rc \
    $(DEVICE_PATH)/recovery/root/first_stage_ramdisk/fstab.emmc:vendor_ramdisk/fstab.emmc \
    $(DEVICE_PATH)/recovery/root/first_stage_ramdisk/fstab.emmc:$(TARGET_COPY_OUT_RAMDISK)/fstab.emmc \
    $(DEVICE_PATH)/rootdir/etc/fstab.mt6877:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.emmc
# vendor_ramdisk (first-stage init): needs fstab.mt6877 name too
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/first_stage_ramdisk/fstab.emmc:vendor_ramdisk/fstab.mt6877 \
    $(DEVICE_PATH)/recovery/root/first_stage_ramdisk/fstab.emmc:$(TARGET_COPY_OUT_RAMDISK)/fstab.mt6877
# vendor/etc full fstab
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/etc/fstab.mt6877:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6877
# APN database - full_base_telephony.mk ships no APN file
PRODUCT_COPY_FILES += \
    device/sample/etc/apns-full-conf.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/apns-conf.xml
# ==============================================================================
# KERNEL MODULES
# ==============================================================================
# Ramdisk modules (recovery & first-stage init)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(DEVICE_PATH)/prebuilts/modules/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/prebuilts/modules/modules.load))
# Vendor partition modules (persistent after switch_root - the boot-critical ones)
#BOARD_VENDOR_KERNEL_MODULES := $(wildcard $(DEVICE_PATH)/prebuilts/modules/*.ko)
#BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/prebuilts/modules/modules.load))
# Vendor DLKM modules (GPU, camera, modem, WiFi, audio, etc.)
BOARD_VENDOR_DLKM_KERNEL_MODULES := $(wildcard $(DEVICE_PATH)/prebuilts/vendor_dlkm/*.ko)
BOARD_VENDOR_DLKM_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/prebuilts/vendor_dlkm/modules.load))
# System DLKM modules (networking, bluetooth, virtio, zram, etc.)
# FIXME: both BOARD_ and PRODUCT_COPY_FILES approaches cause bootloops
# when this partition is populated. Root cause unknown. Keep empty for now.
BOARD_SYSTEM_DLKM_KERNEL_MODULES := $(wildcard $(DEVICE_PATH)/prebuilts/system_dlkm/*.ko)
BOARD_SYSTEM_DLKM_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/prebuilts/system_dlkm/modules.load))
# PRODUCT_COPY_FILES += $(foreach f,$(wildcard device/rainx/theloop/prebuilts/system_dlkm/*.ko),$(f):$(TARGET_COPY_OUT_SYSTEM_DLKM)/lib/modules/$(notdir $(f)))
# PRODUCT_COPY_FILES += device/rainx/theloop/prebuilts/system_dlkm/modules.load:$(TARGET_COPY_OUT_SYSTEM_DLKM)/lib/modules/modules.load
# PRODUCT_COPY_FILES += device/rainx/theloop/prebuilts/system_dlkm/modules.dep:$(TARGET_COPY_OUT_SYSTEM_DLKM)/lib/modules/modules.dep
# PRODUCT_COPY_FILES += device/rainx/theloop/prebuilts/system_dlkm/modules.alias:$(TARGET_COPY_OUT_SYSTEM_DLKM)/lib/modules/modules.alias
# PRODUCT_COPY_FILES += device/rainx/theloop/prebuilts/system_dlkm/modules.softdep:$(TARGET_COPY_OUT_SYSTEM_DLKM)/lib/modules/modules.softdep
# Ramdisk support files (init.insmod.sh and cfg)
# A16 fsgen neverallows vendor_ramdisk installs via PRODUCT_COPY_FILES;
# route through recovery/root/ - BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT
# embeds these into vendor_boot.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/bin/init.insmod.sh:recovery/root/vendor/bin/init.insmod.sh \
    $(DEVICE_PATH)/rootdir/etc/init.insmod.mt6877.cfg:recovery/root/vendor/etc/init.insmod.mt6877.cfg \
    $(DEVICE_PATH)/rootdir/etc/init.insmod.mt6877.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/init.insmod.mt6877.cfg
# Do not set PRODUCT_ENFORCE_VINTF_MANIFEST_OVERRIDE := false;
# it makes PRODUCT_FULL_TREBLE false, breaking linker namespaces.

# PRODUCT_FULL_TREBLE_OVERRIDE removed - obsolete in A16, hard-errors the build.

# Vendor bin scripts
PRODUCT_COPY_FILES += \
    device/rainx/theloop/rootdir/bin/init.insmod.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.insmod.sh \
    device/rainx/theloop/rootdir/bin/init.pstore_blk.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.pstore_blk.sh 

# Disable RescueParty
PRODUCT_VENDOR_PROPERTIES += persist.sys.disable_rescue=true

# MTK RIL daemon.
# Do not set vendor.ril.mtk=1 statically - it must be set dynamically by
# gsm0710muxd after modem init. Static set causes mtkfusionrild to start
# before muxd exists, triggering modem bootloop.
PRODUCT_VENDOR_PROPERTIES += vendor.rild.libpath=mtk-ril.so

# No headphone jack; bypass FMRadio antenna check (FmUtils.hasBuiltInFmAntennaSupport)
PRODUCT_VENDOR_PROPERTIES += ro.vendor.builtin_fm_antenna_support=1

# Properties moved to vendor.prop to avoid duplicate sysprop errors:
#   debug.renderengine.backend=skiavk  (skiagl crashes SF on MTK EGL)
#   persist.vendor.vilte_support=0     (prevents vtservice crash-loop)
#   persist.vendor.viwifi_support=0    (same)

# Recovery fstab - routed through recovery/root/ to avoid A16 fsgen neverallow
# on vendor_ramdisk/etc/. Goes to /system/etc/ (not /etc/ - conflicts with symlink).
PRODUCT_COPY_FILES += device/rainx/theloop/rootdir/etc/fstab.mt6877:recovery/root/system/etc/recovery.fstab
PRODUCT_SHIPPING_API_LEVEL := 35
PRODUCT_COPY_FILES += device/rainx/theloop/rootdir/bin/fsverity_init:$(TARGET_COPY_OUT_SYSTEM)/bin/fsverity_init
PRODUCT_COPY_FILES += device/rainx/theloop/rootdir/bin/force_usb.sh:$(TARGET_COPY_OUT_VENDOR)/bin/force_usb.sh

# Audio effects config overlay: fix missing spatializersw and undefined env_reverbsw
PRODUCT_COPY_FILES += device/rainx/theloop/rootdir/etc/audio_effects_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects_config.xml

# WiFi vendor HAL descriptor: A16 wifi-service-lazy discovers vendor HALs
# via XML in /vendor/etc/wifi/vendor_hals/ instead of static linking.
PRODUCT_COPY_FILES += device/rainx/theloop/wifi/mtk_vendor_hal.xml:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/vendor_hals/mtk_vendor_hal.xml

# Stock MTK AIDL audio HAL. Earlier stack smash was caused by V4 NDK libs
# in /vendor/lib64 instead of V3; fixed in proprietary-files.txt.
# soundtrigger3 ISoundTriggerHw/default must be declared or the HAL aborts.

# tinyalsa tools for audio debugging
PRODUCT_PACKAGES += tinymix tinyplay tinycap tinypcminfo

# AOSP V1 USB gadget HAL - replaces crashing stock MTK binary.
# Without IUsbGadget/default, UsbService blocks display thread 60+s.
# init.rc overrides vendor.usb_gadget_default.
PRODUCT_PACKAGES += android.hardware.usb.gadget-service.theloop

# Media Codec2 IComponentStore/default stub.
# Stock media.c2-mediatek crash-loops (missing libcodec2_hal_common.so in A15).
# Without /default, mediaserver blocks, system_server watchdog fires, bootloop.
# Stub registers zero components; decoding falls through to /software.
# IMPORTANT: theloop-vendor.mk must not install the mediatek .rc - its init
# service name collides with the stub's .rc.
PRODUCT_PACKAGES += \
    android.hardware.media.c2-default-service \
    android.hardware.media.c2-default-seccomp_policy

# LatinIME not included by common.mk (minimal); only in common_mobile.mk
PRODUCT_PACKAGES += LatinIME

# AudioFX - not in common.mk (minimal), only common_full.mk
PRODUCT_PACKAGES += AudioFX

# OpenEUICC - privileged FOSS LPA (EuiccService). Provides Settings
# eSIM management for the two soldered eUICCs (no OEM LPA on stock).
# Built from source via .repo/local_manifests/rainx_theloop.xml.
# Requires repo sync before breakfast so Soong sees the modules.
# Prerequisites: overlay non_removable_euicc_slots=[0,1],
#   product.prop masterclear.allow_retain_esim_profiles_after_fdr=1
PRODUCT_PACKAGES += OpenEUICC

# SMS/MMS UI - full_base_telephony.mk has no user-facing SMS app
PRODUCT_PACKAGES += messaging

# Camera disabled. MTK ISP profile registration is broken on lineage
# (HalIspImp returns empty profile, V4L2 never dequeues). Camera HAL
# libs remain in /vendor/lib64 but are never loaded (manifest removed,
# camerahalserver.rc not copied).
# To re-enable: restore Aperture, un-comment camera xml/rc in
# theloop-vendor.mk, point DEVICE_MANIFEST_FILE at manifest.xml,
# then fix ISP profile registration in framework.jar.
# PRODUCT_NO_CAMERA prevents Aperture; NoCameraStub overrides Camera2,
# DeviceAsWebcam, CameraExtensions.
PRODUCT_NO_CAMERA := true
PRODUCT_PACKAGES += NoCameraStub

# DuraSpeed: MTK app freezer; NPE-spams without native IDuraSpeedService
PRODUCT_PACKAGES_REMOVE += DuraSpeed

# Framework-level camera disable (product context; vendor_init can't set config_prop)
PRODUCT_PRODUCT_PROPERTIES += config.disable_camera=true
PRODUCT_PROPERTY_OVERRIDES += ro.camera.sound.forced=0

# Battery charging control via LineageOS health HAL (Settings > Battery)
PRODUCT_PACKAGES += vendor.lineage.health-service.default

# Gallery / image viewer
PRODUCT_PACKAGES += Glimpse

# Override stock vendor init.rc with our modified version (USB VID, UAC2)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init.mt6877.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.mt6877.usb.rc

# Smart speaker QOL
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init.smart_speaker.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.smart_speaker.rc \
    $(LOCAL_PATH)/rootdir/etc/smart_speaker_defaults.sh:$(TARGET_COPY_OUT_VENDOR)/etc/smart_speaker_defaults.sh
PRODUCT_PRODUCT_PROPERTIES += \
    ro.config.haptics_disabled=true \
    ro.config.vibrate_input_devices=false \
    ro.config.notification_vibration_intensity=0 \
    ro.config.ring_vibration_intensity=0 \
    ro.config.alarm_alert=Alarm_Classic.ogg \
    ro.lockscreen.disable.default=false \
    audio.safemedia.bypass=true \
    ro.config.hw_quickpoweron=false
PRODUCT_PROPERTY_OVERRIDES += persist.sys.animator_duration_scale=0.5

# Prevent SIM MCC from overriding locale during OOB
PRODUCT_PROPERTY_OVERRIDES += persist.sys.locale=en-GB

# Force locale to English - Chinese IoT eSIM MCC overrides during setup otherwise
PRODUCT_LOCALES := en_GB

# Signing: build with test keys, re-sign with private keys post-build.
# Use: sign_target_files_apks -o -d device/rainx/theloop/.keys \
#   out/target/product/theloop/obj/PACKAGING/target_files_intermediates/*-target_files*.zip \
#   signed-target_files.zip
# Then: ota_from_target_files signed-target_files.zip signed-ota.zip


# USB Audio Gadget
PRODUCT_PACKAGES += usb_audio_loopback
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/usb_audio_loopback/usb_audio_loopback.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/usb_audio_loopback.rc

# NFC: no hardware on theloop
PRODUCT_PACKAGES_REMOVE += NfcNci NQNfcNci SecureElement

# Patched handheld_core_hardware.xml with camera feature stripped.
# Replaces both vendor copies (handheld_core_hardware.xml + .prebuilt.xml).
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/permissions/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml \
    $(LOCAL_PATH)/permissions/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.prebuilt.xml

# Stock libtinyxml2 - AOSP source build is ABI-incompatible with MTK vendor
# HALs (audio, power, PQ all crash with null deref). Use PRODUCT_COPY_FILES
# to bypass Soong module conflicts.
PRODUCT_COPY_FILES += \
    vendor/rainx/theloop/proprietary/vendor/lib64/libtinyxml2.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libtinyxml2.so \
    vendor/rainx/theloop/proprietary/vendor/lib/libtinyxml2.so:$(TARGET_COPY_OUT_VENDOR)/lib/libtinyxml2.so \
    vendor/rainx/theloop/proprietary/vendor/lib64/libtinyxml2.so:$(TARGET_COPY_OUT_SYSTEM)/lib64/libtinyxml2.so \
    vendor/rainx/theloop/proprietary/vendor/lib/libtinyxml2.so:$(TARGET_COPY_OUT_SYSTEM)/lib/libtinyxml2.so

# Etar + Seedvault: not in common.mk (minimal), only common_mobile_full.mk
PRODUCT_PACKAGES += \
    Etar \
    Seedvault

# OpenEUICC privapp permission allowlist
PRODUCT_COPY_FILES += \
    device/rainx/theloop/permissions/privapp_whitelist_im.angry.openeuicc.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp_whitelist_im.angry.openeuicc.xml

# SystemUI privapp permissions allowlist for system_ext partition
PRODUCT_COPY_FILES += device/rainx/theloop/permissions/privapp-permissions-systemui.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-systemui.xml

# A15 renamed av-audio-types-aidl-V1-ndk; stock service still needs V1 name
PRODUCT_COPY_FILES += vendor/rainx/theloop/proprietary/system_ext/lib64/av-audio-types-aidl-V1-ndk.so:$(TARGET_COPY_OUT_SYSTEM_EXT)/lib64/av-audio-types-aidl-V1-ndk.so

# Stock WiFi HAL links libwifi-system-iface.so; vendor namespace can't see /system.
# Android.bp prefer:true causes partition mismatch; use PRODUCT_COPY_FILES instead.
PRODUCT_COPY_FILES += \
    vendor/rainx/theloop/proprietary/vendor/lib64/libwifi-system-iface.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libwifi-system-iface.so

# GKI modules needed by vendor drivers (rfkill for WiFi/BT, bluetooth for bt_drv_6877).
# Installed to vendor_dlkm since system_dlkm population causes bootloops (FIXME above).
PRODUCT_COPY_FILES += \
    device/rainx/theloop/prebuilts/system_dlkm/rfkill.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/rfkill.ko \
    device/rainx/theloop/prebuilts/system_dlkm/bluetooth.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/bluetooth.ko

# GPU kernel modules (force install to vendor_dlkm)
PRODUCT_COPY_FILES += \
    device/rainx/theloop/prebuilts/vendor_dlkm/ged.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/ged.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/sspm.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/sspm.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_gpu_hal.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_gpu_hal.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_gpu_qos.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_gpu_qos.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_gpufreq_mt6877.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_gpufreq_mt6877.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_gpufreq_wrapper_legacy.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_gpufreq_wrapper_legacy.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mali_prot_alloc_mt6877_r49.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mali_prot_alloc_mt6877_r49.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mali_mgm_mt6877_r49.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mali_mgm_mt6877_r49.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mali_kbase_mt6877_r49.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mali_kbase_mt6877_r49.ko
PRODUCT_COPY_FILES += device/rainx/theloop/prebuilts/vendor_dlkm/modules.load:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/modules.load
PRODUCT_COPY_FILES += device/rainx/theloop/prebuilts/vendor_dlkm/modules.dep:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/modules.dep
PRODUCT_COPY_FILES += device/rainx/theloop/prebuilts/vendor_dlkm/modules.alias:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/modules.alias
PRODUCT_COPY_FILES += device/rainx/theloop/prebuilts/vendor_dlkm/modules.softdep:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/modules.softdep

# Force-install ALL missing vendor_dlkm modules
PRODUCT_COPY_FILES += \
    device/rainx/theloop/prebuilts/vendor_dlkm/CPU_DVFS.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/CPU_DVFS.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/Upower.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/Upower.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/apu_top.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/apu_top.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/apusys.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/apusys.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/archcounter_timesync.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/archcounter_timesync.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/arm_dsu_pmu.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/arm_dsu_pmu.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/atf_logger.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/atf_logger.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/bt_drv_6877.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/bt_drv_6877.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/btif_drv.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/btif_drv.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/c2k_usb.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/c2k_usb.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/c2k_usb_f_via_atc.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/c2k_usb_f_via_atc.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/c2k_usb_f_via_ets.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/c2k_usb_f_via_ets.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/c2k_usb_f_via_modem.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/c2k_usb_f_via_modem.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/cam_qos.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/cam_qos.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/camera_dip_isp6s.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/camera_dip_isp6s.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/camera_dpe_isp60.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/camera_dpe_isp60.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/camera_eeprom_isp6s_mon.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/camera_eeprom_isp6s_mon.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/camera_fdvt_isp51.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/camera_fdvt_isp51.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/camera_isp.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/camera_isp.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/camera_mem.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/camera_mem.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/camera_mfb_isp6s.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/camera_mfb_isp6s.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/camera_rsc_isp6s.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/camera_rsc_isp6s.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/camera_wpe_isp6s.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/camera_wpe_isp6s.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/ccci_auxadc.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/ccci_auxadc.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/ccci_ccif.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/ccci_ccif.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/ccci_cldma.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/ccci_cldma.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/ccci_dpmaif.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/ccci_dpmaif.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/ccci_md_all.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/ccci_md_all.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/ccci_util_lib.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/ccci_util_lib.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/ccmni.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/ccmni.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/ccu_isp6s.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/ccu_isp6s.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/cfg80211.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/cfg80211.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/clk-disable-unused.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/clk-disable-unused.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/cmdq-sec-drv.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/cmdq-sec-drv.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/cmdq-test.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/cmdq-test.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/connadp.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/connadp.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/connfem.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/connfem.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/conninfra.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/conninfra.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/cpufreq_sugov_ext.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/cpufreq_sugov_ext.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/cpuqos_ext.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/cpuqos_ext.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/eas_ext.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/eas_ext.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/emi-mpu-test.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/emi-mpu-test.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/fhctl.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/fhctl.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/flashlight.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/flashlight.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/fmradio_drv_connac2x.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/fmradio_drv_connac2x.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/focaltech_touch_i2c_v42.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/focaltech_touch_i2c_v42.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/fpsgo.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/fpsgo.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/gps_drv_dl_v030.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/gps_drv_dl_v030.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/gz_ipc_mod.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/gz_ipc_mod.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/gz_irq_mod.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/gz_irq_mod.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/gz_log_mod.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/gz_log_mod.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/gz_main_mod.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/gz_main_mod.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/gz_trusty_mod.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/gz_trusty_mod.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/gz_tz_system.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/gz_tz_system.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/gz_virtio_mod.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/gz_virtio_mod.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/hf_manager.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/hf_manager.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/imgsensor_isp6s_mon.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/imgsensor_isp6s_mon.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/iommu_gz.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/iommu_gz.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/leds-mt6360.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/leds-mt6360.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/legacy_gt9896s.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/legacy_gt9896s.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mac80211.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mac80211.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/main2af.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/main2af.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/main3af.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/main3af.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mainaf.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mainaf.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mcupm.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mcupm.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mddp.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mddp.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mdp_drv_mt6877.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mdp_drv_mt6877.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mediatek_eem.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mediatek_eem.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mediatek_static_power.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mediatek_static_power.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/met.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/met.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/met_backlight_api.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/met_backlight_api.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/met_emi_api.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/met_emi_api.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/met_gpu_adv_api.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/met_gpu_adv_api.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/met_gpu_api.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/met_gpu_api.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/met_ipi_api.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/met_ipi_api.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/met_mcupm_api.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/met_mcupm_api.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/met_scmi_api.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/met_scmi_api.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/met_sspm_api.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/met_sspm_api.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/met_vcore_api.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/met_vcore_api.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mt63xx-debug.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mt63xx-debug.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mt6877-mt6359.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mt6877-mt6359.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mt6877_dcm.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mt6877_dcm.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-btcvsd.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-btcvsd.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-composite.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-composite.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-dvfsrc-devfreq.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-dvfsrc-devfreq.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-dvfsrc-helper.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-dvfsrc-helper.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-dvfsrc-start.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-dvfsrc-start.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-extbuck-debug.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-extbuck-debug.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-lpm-dbg-common-v1-legacy.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-lpm-dbg-common-v1-legacy.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-lpm-dbg-mt6877-legacy.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-lpm-dbg-mt6877-legacy.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-lpm-legacy.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-lpm-legacy.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-lpm-plat-v1-legacy.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-lpm-plat-v1-legacy.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-mbox.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-mbox.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-pm-domain-disable-unused.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-pm-domain-disable-unused.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-pwm.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-pwm.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-scp-ultra.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-scp-ultra.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-scp-vow.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-scp-vow.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-sp-spk-amp.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-sp-spk-amp.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-vcodec-common.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-vcodec-common.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-vcodec-dec-v1.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-vcodec-dec-v1.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-vcodec-enc-v1.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-vcodec-enc-v1.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-vcu.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-vcu.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk-vow.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk-vow.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_battery_oc_throttling.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_battery_oc_throttling.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_cm_mgr.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_cm_mgr.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_cm_mgr_mt6877.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_cm_mgr_mt6877.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_cpu_power_throttling.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_cpu_power_throttling.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_dcm.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_dcm.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_disp_sec.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_disp_sec.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_dynamic_loading_throttling.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_dynamic_loading_throttling.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_eem.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_eem.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_em.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_em.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_fpsgo.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_fpsgo.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_heap_debug.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_heap_debug.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_ioctl_powerhal.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_ioctl_powerhal.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_ioctl_touch_boost.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_ioctl_touch_boost.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_irtx_pwm.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_irtx_pwm.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_jpeg.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_jpeg.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_low_battery_throttling.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_low_battery_throttling.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_md_power_throttling.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_md_power_throttling.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_mdpm_v1.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_mdpm_v1.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_pbm.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_pbm.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_peak_power_budget.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_peak_power_budget.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_perf_common.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_perf_common.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_perf_ioctl.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_perf_ioctl.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_picachu.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_picachu.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_ppm_v3.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_ppm_v3.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_qos.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_qos.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_rpmsg_mbox.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_rpmsg_mbox.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_sec_heap.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_sec_heap.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_tinysys_ipi.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_tinysys_ipi.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_u_ether.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_u_ether.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/mtk_usb_f_rndis.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/mtk_usb_f_rndis.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/nanohub.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/nanohub.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/nvmem-mt635x-efuse.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/nvmem-mt635x-efuse.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/powerhal_cpu_ctrl.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/powerhal_cpu_ctrl.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/richtek_spm_cls.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/richtek_spm_cls.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/rps_perf.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/rps_perf.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/scheduler.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/scheduler.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/scp.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/scp.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/sitronix_touch.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/sitronix_touch.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/snd-soc-dummypa.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/snd-soc-dummypa.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/snd-soc-mt6359.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/snd-soc-mt6359.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/snd-soc-mt6877-afe.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/snd-soc-mt6877-afe.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/snd-soc-mtk-common.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/snd-soc-mtk-common.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/snd-soc-mtk-scp-ultra.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/snd-soc-mtk-scp-ultra.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/snd-soc-rt5512.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/snd-soc-rt5512.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/sub2af.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/sub2af.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/subaf.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/subaf.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/task_turbo.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/task_turbo.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/thermal_monitor.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/thermal_monitor.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/touch_boost.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/touch_boost.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/trace_mmstat.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/trace_mmstat.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/trusted_mem.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/trusted_mem.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/tui-common.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/tui-common.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/usb_boost.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/usb_boost.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/v4l2-flash-led-class.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/v4l2-flash-led-class.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/widevine_driver.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/widevine_driver.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/wlan_drv_gen4m_6877.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/wlan_drv_gen4m_6877.ko \
    device/rainx/theloop/prebuilts/vendor_dlkm/wmt_chrdev_wifi_connac2.ko:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/wmt_chrdev_wifi_connac2.ko

PRODUCT_COPY_FILES += device/rainx/theloop/rootdir/bin/load_gpu_modules.sh:$(TARGET_COPY_OUT_VENDOR)/bin/load_gpu_modules.sh

# GPU kernel modules
PRODUCT_COPY_FILES += \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/ged.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/ged.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mali_kbase_mt6877_r49.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mali_kbase_mt6877_r49.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mali_mgm_mt6877_r49.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mali_mgm_mt6877_r49.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mali_prot_alloc_mt6877_r49.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mali_prot_alloc_mt6877_r49.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk-mbox.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk-mbox.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_battery_oc_throttling.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_battery_oc_throttling.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_cm_mgr.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_cm_mgr.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_cm_mgr_mt6877.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_cm_mgr_mt6877.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_cpu_power_throttling.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_cpu_power_throttling.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_dynamic_loading_throttling.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_dynamic_loading_throttling.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_gpu_hal.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_gpu_hal.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_gpu_qos.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_gpu_qos.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_gpufreq_mt6877.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_gpufreq_mt6877.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_gpufreq_wrapper_legacy.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_gpufreq_wrapper_legacy.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_low_battery_throttling.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_low_battery_throttling.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_md_power_throttling.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_md_power_throttling.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_mdpm_v1.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_mdpm_v1.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_pbm.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_pbm.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_peak_power_budget.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_peak_power_budget.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_qos.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_qos.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_rpmsg_mbox.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_rpmsg_mbox.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/mtk_tinysys_ipi.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/mtk_tinysys_ipi.ko \
    vendor/rainx/theloop/proprietary/vendor/etc/gpu_ko/sspm.ko:$(TARGET_COPY_OUT_VENDOR)/etc/gpu_ko/sspm.ko

# MediaTek PQ AIDL Framework Compatibility Matrix
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += device/rainx/theloop/vintf/pq_compatibility_matrix.xml
