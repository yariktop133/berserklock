TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES := SpringBoard
THEOS_PACKAGE_SCHEME := rootless
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := BerserkLock

BerserkLock_FILES := Tweak.x BerserkClockView.m BerserkLightningOverlayView.m BerserkRunicRenderer.m BerserkHomeWidgetView.m
BerserkLock_CFLAGS := -fobjc-arc -O3 -Wall
BerserkLock_FRAMEWORKS := UIKit CoreGraphics QuartzCore AudioToolbox

include $(THEOS_MAKE_PATH)/tweak.mk
