TARGET := iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = WeChat
ARCHS = arm64 arm64e

ifeq ($(SCHEME),roothide)
    export THEOS_PACKAGE_SCHEME = roothide
else ifeq ($(SCHEME),rootless)
    export THEOS_PACKAGE_SCHEME = rootless
else
    unexport THEOS_PACKAGE_SCHEME
endif

export DEBUG = 0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WCDuang

$(TWEAK_NAME)_FILES = $(shell find . -name "*.m" -o -name "*.xm")
$(TWEAK_NAME)_CFLAGS += -fobjc-arc -Wno-deprecated-declarations -Wno-vla-cxx-extension -Wno-unused-variable
$(TWEAK_NAME)_CCFLAGS += -fno-modules -fno-cxx-modules
$(TWEAK_NAME)_FRAMEWORKS += Security SafariServices AudioToolbox AVFoundation

THEOS_DEVICE_IP = 192.168.31.227
THEOS_DEVICE_PORT = 22

include $(THEOS_MAKE_PATH)/tweak.mk

clean::
	@echo -e "\033[31m==>\033[0m Cleaning packages…"
	@rm -rf .theos packages/*

dylib::
	@echo -e "\033[33m==>\033[0m Building dylib..."
	@$(MAKE) all
	@echo -e "\033[32m==>\033[0m Moving dylib to packages..."
	@mkdir -p packages
	@mv .theos/obj/*.dylib packages/

after-package::
	@echo -e "\033[32m==>\033[0m Packaging complete."
	@if [ "$(INSTALL)" = "1" ]; then \
        DEB_FILE=$$(ls -t packages/*.deb | head -1); \
        scp -P $(THEOS_DEVICE_PORT) $${DEB_FILE} root@$(THEOS_DEVICE_IP):/tmp; \
        ssh -p $(THEOS_DEVICE_PORT) root@$(THEOS_DEVICE_IP) "dpkg -i /tmp/$$(basename $${DEB_FILE})"; \
    fi