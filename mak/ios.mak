## Makefile rules for iOS apps

ifndef BASE_DIR
$(error You have to define the BASE_DIR)
endif

ifndef PRODUCT_NAME
$(error You have to define a PRODUCT_NAME)
endif

EXECUTABLE_NAME=$(PRODUCT_NAME)
INFO_PLIST=$(PRODUCT_NAME)-Info.plist

SRCS=$(wildcard *.m)
OBJS=$(patsubst %.m,%.o,$(SRCS))

DEVELOPER_PATH=$(shell xcode-select -print-path)
PLATFORM_DIR=$(DEVELOPER_PATH)/Platforms

ifeq ($(SIMULATOR),1)
IOS_SDK=$(PLATFORM_DIR)/iPhoneSimulator.platform/Developer/SDKs
else
IOS_SDK=$(PLATFORM_DIR)/iPhoneOS.platform/Developer/SDKs
endif

ifndef ARCH
ifeq ($(SIMULATOR),1)
ARCH=x86_64
else
ARCH=armv7
endif
endif

# FIXME: the SDK version should be automatically determined
ifndef SDK_VERSION
SDK_VERSION=9.2
endif

ifeq ($(SIMULATOR),1)
SDK=iPhoneSimulator$(SDK_VERSION).sdk
else
SDK=iPhoneOS$(SDK_VERSION).sdk
endif

ifndef SIMULATED_DEVICE
SIMULATED_DEVICE="iPhone 5s"
endif

CC=clang
CFLAGS=-ObjC -arch $(ARCH) -include $(PRODUCT_NAME)-Prefix.pch \
			 -isysroot $(IOS_SDK)/$(SDK)

LD=$(CC)
LDFLAGS+=-framework Foundation -framework UIKit

PLBUDDY=/usr/libexec/PlistBuddy

.PHONY: all bundleid clean device package

all: package

bundleid:
	@$(BASE_DIR)/sh/bundleid

clean:
	rm -f $(EXECUTABLE_NAME) $(OBJS) $(PRODUCT_NAME).ipa Entitlements.plist
	@rm -f "$(PRODUCT_NAME).app/_CodeSignature"/*
	@(rmdir "$(PRODUCT_NAME).app/_CodeSignature" 2>/dev/null; exit 0)
	rm -f "$(PRODUCT_NAME).app"/*
	@(rmdir "$(PRODUCT_NAME).app" 2>/dev/null; exit 0)

device: package

package: $(EXECUTABLE_NAME) $(INFO_PLIST)
	mkdir -p "$(PRODUCT_NAME).app"
	@/bin/echo -n 'AAPL' > "$(PRODUCT_NAME).app/PkgInfo"
	@$(PLBUDDY) -c 'Print CFBundleSignature' $(INFO_PLIST) \
		>> "$(PRODUCT_NAME).app/PkgInfo"
	cp $(EXECUTABLE_NAME) "$(PRODUCT_NAME).app"
	$(BASE_DIR)/sh/build_plist $(INFO_PLIST) "$(PRODUCT_NAME).app/Info.plist"
	$(BASE_DIR)/sh/build_ipa "$(PRODUCT_NAME).app"

$(EXECUTABLE_NAME): $(OBJS)
	$(LD) $(CFLAGS) $(LDFLAGS) -o $@ $^
