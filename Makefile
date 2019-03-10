TARGET = iphone:latest:11.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CCOnOff
CCOnOff_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
