export TARGET = iphone:clang:latest:15.0
export ARCHS = arm64 arm64e
export ROOTLESS = 1
export ROOTHIDE = 1

INSTALL_TARGET_PROCESSES = SpringBoard mediaserverd cameracaptured

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Vcam_Mch Vcam_Mch_AntiBank

Vcam_Mch_FILES = Tweak.x
Vcam_Mch_CFLAGS = -fobjc-arc
Vcam_Mch_FRAMEWORKS = AVFoundation CoreVideo CoreMedia UIKit

Vcam_Mch_AntiBank_FILES = AntiBank.x
Vcam_Mch_AntiBank_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += VcamApp VcamDaemon
include $(THEOS_MAKE_PATH)/aggregate.mk
