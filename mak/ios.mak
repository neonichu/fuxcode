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
IOS_SDK=$(DEVELOPER_PATH)/Platforms/iPhoneOS.platform/Developer/SDKs

ifndef ARCH
ARCH=armv7
endif

ifndef SDK
SDK=iPhoneOS8.1.sdk
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
