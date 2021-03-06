#
# Copyright (C) Imagination Technologies Ltd. All rights reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 2, as published by the Free Software Foundation.
# 
# This program is distributed in the hope it will be useful but, except 
# as otherwise stated in writing, without any warranty; without even the 
# implied warranty of merchantability or fitness for a particular purpose. 
# See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
# 
# The full GNU General Public License is included in this distribution in
# the file called "COPYING".
#
# Contact Information:
# Imagination Technologies Ltd. <gpl-support@imgtec.com>
# Home Park Estate, Kings Langley, Herts, WD4 8LZ, UK 
# 
#

#
# This file is read once at the start of the build, after reading in
# config.mk. It should define the non-MODULE_* variables used in commands,
# like ALL_CFLAGS
#

ifeq ($(BUILD),debug)
COMMON_FLAGS := -O0
else
OPTIM ?= -O2
COMMON_FLAGS := $(OPTIM)
endif

ifeq ($(OMAPES), 6.x)
COMMON_FLAGS += -DPLAT_TI81xx
endif

# FIXME: We should probably audit the driver for aliasing
#
COMMON_FLAGS += -fno-strict-aliasing

# We always enable debugging. Either the release binaries are stripped
# and the symbols put in the symbolpackage, or we're building debug.
#
COMMON_FLAGS += -g

# These flags are used for kernel, User C and User C++
#
COMMON_FLAGS += \
 -W -Wall -Wno-missing-field-initializers -Wmissing-format-attribute

# Some GCC warnings are C only, so we must mask them from C++
#
COMMON_CFLAGS := $(COMMON_FLAGS) \
 -Wdeclaration-after-statement -Wno-format-zero-length \
 -Wmissing-prototypes -Wstrict-prototypes

# If we saw W=1, turn on some extra warnings.
# Most of these flags are new, so cc-option check them.
#
ifeq ($(W),1)
COMMON_CFLAGS += \
 $(call cc-option,-Waggregate-return) \
 $(call cc-option,-Wbad-function-cast) \
 $(call cc-option,-Wcast-qual) \
 $(call cc-option,-Wcast-align) \
 $(call cc-option,-Wconversion) \
 $(call cc-option,-Wdisabled-optimization) \
 $(call cc-option,-Wlogical-op) \
 $(call cc-option,-Wmissing-declarations) \
 $(call cc-option,-Wmissing-include-dirs) \
 $(call cc-option,-Wnested-externs) \
 $(call cc-option,-Wold-style-definition) \
 $(call cc-option,-Woverlength-strings) \
 $(call cc-option,-Wpacked) \
 $(call cc-option,-Wpacked-bitfield-compat) \
 $(call cc-option,-Wpadded) \
 $(call cc-option,-Wredundant-decls) \
 $(call cc-option,-Wshadow) \
 $(call cc-option,-Wswitch-default) \
 $(call cc-option,-Wvla) \
 $(call cc-option,-Wwrite-strings)
endif

# User C only
#
ALL_CFLAGS := \
 $(COMMON_CFLAGS) -Wpointer-arith -Wunused-parameter $(SYS_CFLAGS)
ALL_HOST_CFLAGS := \
 $(COMMON_CFLAGS) -Wpointer-arith -Wunused-parameter

# User C++ only
#
ALL_CXXFLAGS := \
 $(COMMON_FLAGS) -fno-rtti -fno-exceptions \
 -Wpointer-arith -Wunused-parameter $(SYS_CXXFLAGS)

# User C and C++
#
ALL_HOST_LDFLAGS := -L$(HOST_OUT) -Xlinker -rpath-link=$(HOST_OUT)
ALL_LDFLAGS := -L$(TARGET_OUT) -Xlinker -rpath-link=$(TARGET_OUT)

ifneq ($(strip $(TOOLCHAIN)),)
ALL_LDFLAGS += -L$(TOOLCHAIN)/lib -Xlinker -rpath-link=$(TOOLCHAIN)/lib
endif

ifneq ($(strip $(LINKER_RPATH)),)
ALL_LDFLAGS += $(addprefix -Xlinker -rpath=,$(LINKER_RPATH))
endif

ALL_LDFLAGS += $(SYS_LDFLAGS)

# Kernel C only
#
ALL_KBUILD_CFLAGS := $(COMMON_CFLAGS) -Wno-unused-parameter -Wno-sign-compare \
 $(call cc-option,-Wno-type-limits)

# This variable contains a list of all modules built by kbuild
ALL_KBUILD_MODULES :=

# This variable contains a list of all modules which contain C++ source files
ALL_CXX_MODULES :=

# Toolchain triple for cross environment
CROSS_TRIPLE := $(patsubst %-,%,$(CROSS_COMPILE))
