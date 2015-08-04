ARCHS = arm64 armv7

include theos/makefiles/common.mk

TWEAK_NAME = KeyTransition
KeyTransition_FILES = Tweak.xm
KeyTransition_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileNotes"
SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
