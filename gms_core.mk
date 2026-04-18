# MindTheGapps "core" subset for theloop (smart speaker).
# Selected by WITH_GMS_VARIANT=core (default). Use =full for kitchen-sink.
# Targets: YouTube, Play Store, casting, Play Integrity. ~150MB.
# Omits: Velvet (Assistant), SpeechServices, talkback, Exchange, Dialer,
# Calendar/Contacts sync, Markup, Feedback, AndroidAuto.

PRODUCT_SOONG_NAMESPACES += \
    vendor/gapps/arm64 \
    vendor/gapps/common \
    vendor/gapps/overlay

PRODUCT_PACKAGES += \
    GmsCore \
    Phonesky \
    GoogleServicesFramework \
    GooglePartnerSetup \
    libjni_latinimegoogle

# SetupWizard intentionally not installed: MindTheGapps baklava ships it
# but not setupcompat, so OOBE hangs at "Checking Info". LineageSetupWizard
# (from common.mk) handles OOBE instead.

PRODUCT_PACKAGES += \
    default-permissions-google.xml \
    default-permissions-mtg.xml \
    gapps.rc \
    gms_fsverity_cert.der \
    google-hiddenapi-package-allowlist.xml \
    google.xml \
    google_build.xml \
    privapp-permissions-google-product.xml \
    privapp-permissions-google-system-ext.xml \
    privapp-permissions-mtg.xml \
    sysconfig_contextual_search.xml
