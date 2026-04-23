THEOS_PACKAGE_SCHEME ?= rootless

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
  ARCHS := arm64
  TARGET := iphone:clang:latest:15.0
else ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
  ARCHS := arm64
  TARGET := iphone:clang:latest:15.0
else
  ARCHS := arm64 arm64e
  TARGET := iphone:clang:latest:13.0
endif

PACKAGE_VERSION := 1.0.0
FINALPACKAGE    := 1
DEBUG           := 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTSideload

YTSideload_FILES    = Tweak.x
YTSideload_FRAMEWORKS = UIKit Foundation Security
YTSideload_CFLAGS   = -fobjc-arc -DTWEAK_VERSION=\"$(PACKAGE_VERSION)\"

include $(THEOS_MAKE_PATH)/tweak.mk

# Convenience target: extract the .dylib for IPA injection (Sideloadly,
# AltStore, TrollStore, etc.). Runs `make package` first so the .deb exists,
# then unpacks the .dylib into ./build/.
.PHONY: dylib package-all clean-all

dylib: package
	@mkdir -p build
	@DEB=$$(ls -t packages/*.deb 2>/dev/null | head -1); \
	if [ -z "$$DEB" ]; then echo "No .deb found in packages/"; exit 1; fi; \
	echo "Extracting dylib from $$DEB"; \
	TMP=$$(mktemp -d); \
	dpkg-deb -x "$$DEB" "$$TMP"; \
	DYLIB=$$(find "$$TMP" -name 'YTSideload.dylib' | head -1); \
	if [ -z "$$DYLIB" ]; then echo "YTSideload.dylib not found inside deb"; rm -rf "$$TMP"; exit 1; fi; \
	cp "$$DYLIB" build/YTSideload.dylib; \
	rm -rf "$$TMP"; \
	echo "Wrote build/YTSideload.dylib"

# Build all three package schemes in one shot (rootful, rootless, roothide).
package-all:
	$(MAKE) clean && $(MAKE) package THEOS_PACKAGE_SCHEME=
	$(MAKE) clean && $(MAKE) package THEOS_PACKAGE_SCHEME=rootless
	$(MAKE) clean && $(MAKE) package THEOS_PACKAGE_SCHEME=roothide

clean-all: clean
	rm -rf build packages .theos
