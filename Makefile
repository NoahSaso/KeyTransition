ARCHS = arm64 armv7

include theos/makefiles/common.mk

TWEAK_NAME = KeyTransition
KeyTransition_FILES = Tweak.xm
KeyTransition_FRAMEWORKS = UIKit
KeyTransition_PRIVATE_FRAMEWORKS = AudioToolbox

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileNotes"
	#install.exec "killall -9 Preferences"
SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
