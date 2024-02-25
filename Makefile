#
# Makefile for Linux NTFS3 filesystem driver.
#

ifneq ($(KERNELRELEASE),)
# call from kernel build system

# Autodetection if we have a driver for the specific MAJOR.MINOR version of kernel
export KVER_MAJ_MIN := $(shell echo ${KERNELRELEASE} | sed "s/\([0-9]\+\.[0-9]\+\)\..*/\1/g")

include Kbuild

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
PWD	:= $(shell pwd)

# Autodetection if we have a driver for the specific MAJOR.MINOR version of kernel
export KVER_MAJ_MIN := $(shell echo $(KVER) | sed "s/\([0-9]\+\.[0-9]\+\)\..*/\1/g")

export CONFIG_NTFS3_FS=m
export CONFIG_NTFS3_LZX_XPRESS=y

obj-$(CONFIG_NTFS3_FS) := ntfs3/

%.ko:
	$(MAKE) -C $(KDIR) M=$(PWD)

PHONY += all
all: clean ntfs3.ko
	echo $(CONFIG_NTFS3_FS)

PHONY += modules
modules: ntfs3.ko

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
