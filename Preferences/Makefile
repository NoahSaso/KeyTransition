ARCHS = arm64 armv7

include theos/makefiles/common.mk

BUNDLE_NAME = KeyTransition
KeyTransition_FILES = KeyTransition.mm
KeyTransition_INSTALL_PATH = /Library/PreferenceBundles
KeyTransition_FRAMEWORKS = UIKit
KeyTransition_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/KeyTransition.plist$(ECHO_END)
