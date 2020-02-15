ARCHS = arm64
TARGET = iphone:clang:11.2:13.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = WallpaperLoader

WallpaperLoader_FILES = $(wildcard *.m)
WallpaperLoader_INSTALL_PATH = /Library/PreferenceBundles
WallpaperLoader_FRAMEWORKS = UIKit AppSupport
WallpaperLoader_PRIVATE_FRAMEWORKS = Preferences SpringBoardUIServices SpringBoardFoundation
WallpaperLoader_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/WallpaperLoader.plist$(ECHO_END)
