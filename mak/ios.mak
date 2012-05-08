## Makefile rules for iOS apps

ifndef PRODUCT_NAME
$(error You have to define a PRODUCT_NAME)
endif

EXECUTABLE_NAME=$(PRODUCT_NAME)

SRCS=$(wildcard *.m)
OBJS=$(patsubst %.m,%.o,$(SRCS))

DEVELOPER_PATH=$(shell xcode-select -print-path)
IOS_SDK=$(DEVELOPER_PATH)/Platforms/iPhoneOS.platform/Developer/SDKs

ifndef ARCH
ARCH=armv7
endif

ifndef SDK
SDK=iPhoneOS5.1.sdk
endif

CC=clang
CFLAGS=-ObjC -arch $(ARCH) -include $(PRODUCT_NAME)-Prefix.pch \
			 -isysroot $(IOS_SDK)/$(SDK)

LD=$(CC)
LDFLAGS+=-framework Foundation -framework UIKit

.PHONY: all clean debug

all: $(EXECUTABLE_NAME)

clean:
	rm -f $(EXECUTABLE_NAME) $(OBJS)

debug:
	# 1. Build binary Info.plist
	# 2. Build app bundle
	# 3. Sign executable
	# 4. Deploy to device
	# 5. Debug using lldb

$(EXECUTABLE_NAME): $(OBJS)
	$(LD) $(CFLAGS) $(LDFLAGS) -o $@ $^
