#
# Makefile for Linux NTFS3 filesystem driver.
#

export DRIVER_NAME := ntfs3

# Define SYMBOLS / MACROS for which modules to build
export CONFIG_NTFS3_FS=m
export CONFIG_NTFS3_64BIT_CLUSTER=y
export CONFIG_NTFS3_LZX_XPRESS=y
export CONFIG_NTFS3_FS_POSIX_ACL=y
# Kerne 6.9 removed support for old NTFS driver and is replacing with this one.
export CONFIG_NTFS_FS=y

# Add necessary macros to the compiler depending on whan we get on make command
ifeq ($(CONFIG_NTFS3_FS),m)
KBUILD_CFLAGS += -DCONFIG_NTFS3_FS_MODULE
endif

ifeq ($(CONFIG_NTFS3_LZX_XPRESS),y)
KBUILD_CFLAGS += -DCONFIG_NTFS3_LZX_XPRESS
endif

ifeq ($(CONFIG_NTFS3_64BIT_CLUSTER),y)
KBUILD_CFLAGS += -DCONFIG_NTFS3_64BIT_CLUSTER
endif

ifeq ($(CONFIG_NTFS3_LZX_XPRESS),y)
KBUILD_CFLAGS += -DCONFIG_NTFS3_LZX_XPRESS
endif

ifeq ($(CONFIG_NTFS3_FS_POSIX_ACL),y)
KBUILD_CFLAGS += -DCONFIG_NTFS3_FS_POSIX_ACL
endif

# Autodetection if we have a driver for the specific MAJOR.MINOR version of kernel
export KVER_MAJ_MIN := $(shell echo ${KERNELRELEASE} | sed "s/\([0-9]\+\.[0-9]\+\)\..*/\1/g")

ifneq ($(KERNELRELEASE),)
# call from kernel build system

obj-y := $(DRIVER_NAME)/

else
# external module build

EXTRA_FLAGS += -I$(PWD)

#
# KDIR is a path to a directory containing kernel source.
# It can be specified on the command line passed to make to enable the module to
# be built and installed for a kernel other than the one currently running.
# By default it is the path to the symbolic link created when
# the current kernel's modules were installed, but
# any valid path to the directory in which the target kernel's source is located
# can be provided on the command line.
#
# In case we want to compile the module against different kernel version than current one
KVER	?= $(shell uname -r)
KDIR	?= /lib/modules/$(KVER)/build
MDIR	?= /lib/modules/$(KVER)
PWD	:= $(shell pwd)
obj-$(CONFIG_NTFS3_FS) := ntfs3/

%.ko:
	$(MAKE) -C $(KDIR) M=$(PWD)

PHONY += all
all: ${DRIVER_NAME}.ko

PHONY += modules
modules: ${DRIVER_NAME}.ko

PHONY += clean
clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

PHONY += help
help:
	$(MAKE) -C $(KDIR) M=$(PWD) help

PHONY += install
install: 
	rm -f ${MDIR}/kernel/extra/fs/ntfs3/ntfs3.ko
	install -m644 -b -D ntfs/$(KVER_MAJ_MIN)/ntfs3.ko ${MDIR}/kernel/extra/ntfs3/ntfs3.ko
	depmod -aq

PHONY += uninstall
uninstall:
	rm -rf ${MDIR}/kernel/extra/ntfs3/ntfs3.ko
	depmod -aq

endif

.PHONY : $(PHONY)
