# Allow vendor/extra to override any property by setting it first
$(call inherit-product-if-exists, vendor/extra/product.mk)
$(call inherit-product-if-exists, vendor/addons/config.mk)
$(call inherit-product-if-exists, vendor/lineage/audio/audio.mk)
$(call inherit-product-if-exists, vendor/lineage/fonts/fonts.mk)

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.error.receiver.system.apps=com.google.android.gms \
    ro.atrace.core.services=com.google.android.gms,com.google.android.gms.ui,com.google.android.gms.persistent \
    ro.com.google.ime.theme_id=5 \
    drm.service.enabled=true \
    media.mediadrmservice.enable=true \
    persist.sys.disable_rescue=true \
    ro.opa.eligible_device=true

# Setupwizard
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.setupwizard.enterprise_mode=1 \
    ro.setupwizard.esim_cid_ignore=00000001 \
    ro.setupwizard.rotation_locked=true \
    setupwizard.feature.baseline_setupwizard_enabled=true \
    setupwizard.feature.day_night_mode_enabled=true \
    setupwizard.feature.lifecycle_refactoring=true \
    setupwizard.feature.notification_refactoring=true \
    setupwizard.feature.portal_notification=true \
    setupwizard.feature.show_pai_screen_in_main_flow.carrier1839=false \
    setupwizard.feature.show_pixel_tos=true \
    setupwizard.feature.show_support_link_in_deferred_setup=false \
    setupwizard.feature.skip_button_use_mobile_data.carrier1839=true \
    setupwizard.theme=glif_v3_light

PRODUCT_BRAND ?= riceDroid

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

ifeq ($(TARGET_BUILD_VARIANT),userdebug)
# Disable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=0
else
# Enable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=1

# Disable extra StrictMode features on all non-engineering builds
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.strictmode.disable=true
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/lineage/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/lineage/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/lineage/prebuilt/common/bin/50-lineage.sh:$(TARGET_COPY_OUT_SYSTEM)/addon.d/50-lineage.sh

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/addon.d/50-lineage.sh

ifneq ($(strip $(AB_OTA_PARTITIONS) $(AB_OTA_POSTINSTALL_CONFIG)),)
PRODUCT_COPY_FILES += \
    vendor/lineage/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/lineage/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/lineage/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/backuptool_ab.sh \
    system/bin/backuptool_ab.functions \
    system/bin/backuptool_postinstall.sh

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.ota.allow_downgrade=true
endif
endif

# Lineage-specific broadcast actions whitelist
PRODUCT_COPY_FILES += \
    vendor/lineage/config/permissions/lineage-sysconfig.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/lineage-sysconfig.xml

# Lineage-specific init rc file
PRODUCT_COPY_FILES += \
    vendor/lineage/prebuilt/common/etc/init/init.lineage-system_ext.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.lineage-system_ext.rc

# Enable Android Beam on all targets
PRODUCT_COPY_FILES += \
    vendor/lineage/config/permissions/android.software.nfc.beam.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.nfc.beam.xml

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_PRODUCT)/usr/keylayout/Vendor_045e_Product_0719.kl

# This is Lineage!
PRODUCT_COPY_FILES += \
    vendor/lineage/config/permissions/org.lineageos.android.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/org.lineageos.android.xml

# Enforce privapp-permissions whitelist
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.control_privapp_permissions=enforce

# Include AOSP audio files
include vendor/lineage/config/aosp_audio.mk

# Include Lineage audio files
include vendor/lineage/config/lineage_audio.mk

ifneq ($(TARGET_DISABLE_LINEAGE_SDK), true)
# Lineage SDK
include vendor/lineage/config/lineage_sdk_common.mk
endif

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

ifneq ($(TARGET_DISABLE_EPPE),true)
# Require all requested packages to exist
$(call enforce-product-packages-exist-internal,$(wildcard device/*/$(LINEAGE_BUILD)/$(TARGET_PRODUCT).mk),product_manifest.xml rild Calendar Launcher3 Launcher3Go Launcher3QuickStep Launcher3QuickStepGo android.hidl.memory@1.0-impl.vendor vndk_apex_snapshot_package)
endif

# Bootanimation
ifeq ($(SUSHI_BOOTANIMATION),720)
# Sushi Bootanimation 720 by saavedra3
PRODUCT_COPY_FILES += vendor/lineage/bootanimation/sushi_bootanimation_720.zip:$(TARGET_COPY_OUT_SYSTEM)/media/bootanimation.zip
else ifeq ($(SUSHI_BOOTANIMATION),1080)
# Sushi Bootanimation 1080 by saavedra3
PRODUCT_COPY_FILES += vendor/lineage/bootanimation/sushi_bootanimation_1080.zip:$(TARGET_COPY_OUT_SYSTEM)/media/bootanimation.zip
else ifeq ($(SUSHI_BOOTANIMATION),1440)
# Sushi Bootanimation 1440 by saavedra3
PRODUCT_COPY_FILES += vendor/lineage/bootanimation/sushi_bootanimation_1440.zip:$(TARGET_COPY_OUT_SYSTEM)/media/bootanimation.zip
else
PRODUCT_COPY_FILES += vendor/lineage/bootanimation/bootanimation.zip:$(TARGET_COPY_OUT_SYSTEM)/media/bootanimation.zip
endif

# Lineage packages
PRODUCT_PACKAGES += \
    LineageParts \
    LineageSettingsProvider \
    LineageSetupWizard \
    Updater

PRODUCT_COPY_FILES += \
    vendor/lineage/prebuilt/common/etc/init/init.lineage-updater.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.lineage-updater.rc

# Themes
PRODUCT_PACKAGES += \
    LineageBlackTheme \
    LineageThemesStub \
    ThemePicker

# Config
PRODUCT_PACKAGES += \
    SimpleDeviceConfig

# Extra tools in Lineage
PRODUCT_PACKAGES += \
    bash \
    curl \
    getcap \
    htop \
    nano \
    setcap \
    vim

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/curl \
    system/bin/getcap \
    system/bin/setcap

# Filesystems tools
PRODUCT_PACKAGES += \
    fsck.ntfs \
    mkfs.ntfs \
    mount.ntfs

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/fsck.ntfs \
    system/bin/mkfs.ntfs \
    system/bin/mount.ntfs \
    system/%/libfuse-lite.so \
    system/%/libntfs-3g.so

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

PRODUCT_COPY_FILES += \
    vendor/lineage/prebuilt/common/etc/init/init.smartcharge.rc:$(TARGET_COPY_OUT_PRODUCT)/etc/init/init.smartcharge.rc
    
PRODUCT_COPY_FILES += \
    vendor/lineage/prebuilt/common/etc/init/init.openssh.rc:$(TARGET_COPY_OUT_PRODUCT)/etc/init/init.openssh.rc

# Storage manager
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.storage_manager.enabled=true

# These packages are excluded from user builds
PRODUCT_PACKAGES_DEBUG += \
    procmem

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/procmem
endif

# Root
PRODUCT_PACKAGES += \
    adb_root
ifneq ($(TARGET_BUILD_VARIANT),userdebug)
ifeq ($(WITH_SU),true)
PRODUCT_PACKAGES += \
    su
endif
endif

# Dex/ART optimization
PRODUCT_DEXPREOPT_SPEED_APPS += \
    Settings \
    Dialer \
    Contacts \
    DeskClock \
    messaging \
    Eleven \
    SystemUI

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    dalvik.vm.systemuicompilerfilter=speed

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/lineage/overlay/no-rro
PRODUCT_PACKAGE_OVERLAYS += \
    vendor/lineage/overlay/common \
    vendor/lineage/overlay/no-rro

PRODUCT_PACKAGES += \
    NetworkStackOverlay \
    TrebuchetOverlay

# RiceDroidOOS
# Rice properties - used by firmware version
PRODUCT_PRODUCT_PROPERTIES += \
    ro.rice.maintainer=$(RICE_MAINTAINER) \
    ro.rice.code=$(RICE_CODENAME) \
    ro.riseui.code=$(RISE_CODE) \
    ro.rice.packagetype=$(RICE_PACKAGE_TYPE) \
    ro.rice.releasetype=$(RICE_BUILDTYPE) \
    ro.rice.version?=$(RICE_VERSION) \
    ro.rice.chipset?=$(RICE_CHIPSET) \
    ro.rice.build.version=$(LINEAGE_VERSION) \
    ro.rice.display.version?=$(LINEAGE_DISPLAY_VERSION) \
    ro.rice.platform_release_codename=$(RICE_FLAVOR) \
    ro.ricelegal.url=https://www.manginasal.com/

# Extra packages
PRODUCT_PACKAGES += \
    Backgrounds \
    GameSpace \
    RepainterServicePriv \
    ParallelSpacePrebuilt \
    OmniJaws

# Face Unlock
TARGET_FACE_UNLOCK_SUPPORTED ?= true
ifeq ($(TARGET_FACE_UNLOCK_SUPPORTED),true)
PRODUCT_PACKAGES += \
    FaceUnlockService
PRODUCT_SYSTEM_PROPERTIES += \
    ro.face_unlock_service.enabled=$(TARGET_FACE_UNLOCK_SUPPORTED)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.biometrics.face.xml
endif

# Parallel space
PRODUCT_COPY_FILES += \
    vendor/lineage/config/permissions/privapp_whitelist_ink.kscope.parallelspace.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp_whitelist_ink.kscope.parallelspace.xml

# Blurs
ifeq ($(TARGET_ENABLE_BLUR), true)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.sf.blurs_are_expensive=1 \
    ro.surface_flinger.supports_background_blur=1 \
    ro.launcher.blur.appLaunch=0
endif

TARGET_BUILD_APERTURE_CAMERA ?= false
ifeq ($(strip $(TARGET_BUILD_APERTURE_CAMERA)),true)
PRODUCT_PACKAGES += \
    Aperture
endif

# Spoof fingerprint for Google Play Services and SafetyNet
ifeq ($(PRODUCT_OVERRIDE_GMS_FINGERPRINT),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.build.gms_fingerprint=google/raven/raven:13/TQ1A.221205.011/9244662:user/release-keys
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.build.gms_fingerprint=$(PRODUCT_OVERRIDE_GMS_FINGERPRINT)
endif

# Translations
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/crowdin/overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/crowdin/overlay

PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/lineage/build/target/product/security/lineage

include vendor/lineage/config/version.mk

-include vendor/lineage-priv/keys/keys.mk

-include $(WORKSPACE)/build_env/image-auto-bits.mk
-include vendor/lineage/config/partner_gms.mk
include vendor/lineage/config/artifactlist.mk
