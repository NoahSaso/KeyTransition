ARCHS = arm64 armv7
GO_EASY_ON_ME = 1

include theos/makefiles/common.mk

BUNDLE_NAME = KeyTransition
KeyTransition_FILES = KeyTransition.mm BetterPSSliderTableCell.mm KTMakersListController.mm KTMakerTableCell.mm KTExtrasListController.mm KTCustomListItemsController.mm
KeyTransition_INSTALL_PATH = /Library/PreferenceBundles
KeyTransition_FRAMEWORKS = UIKit Twitter
KeyTransition_PRIVATE_FRAMEWORKS = Preferences
ADDITIONAL_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/KeyTransition.plist$(ECHO_END)
