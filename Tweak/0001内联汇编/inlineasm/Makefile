THEOS_DEVICE_IP = 10.66.200.23
ARCHS = arm64
TARGET = iphone:latest:9.0

include theos/makefiles/common.mk

TWEAK_NAME = InlineAsm
InlineAsm_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 ProductName"
