ARCHS = arm64
TARGET = iphone:latest:9.0
export THEOS_DEVICE_IP = 127.0.0.1
export THEOS_DEVICE_PORT = 2222

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = csdn_robot
csdn_robot_FILES = Tweak.xm
csdn_robot_FRAMEWORKS = UIKit
csdn_roboe_CFLAGS = -Wno-ignored-attributes -Wno-unused-variable -Wno-unused-function

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 CsdnPlus"

