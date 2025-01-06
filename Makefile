#
# Makefile for Linux NTFS3 filesystem driver.
#

PWD	?= $(shell pwd)

$(info Makefile: Include Config.mk)
include $(PWD)/Config.mk

# Autodetection if we have a driver for the specific MAJOR.MINOR version of kernel
export KVER_MAJ_MIN := $(shell echo ${KERNELRELEASE} | sed "s/\([0-9]\+\.[0-9]\+\)\..*/\1/g")

ifneq ($(KERNELRELEASE),)
# call from kernel build system

obj-y := $(DRIVER_NAME)/

else
# external module build

$(info Called as external module Build)

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

# Autodetection if we have a driver for the specific MAJOR.MINOR version of kernel
export KVER_MAJ_MIN := $(shell echo ${KVER} | sed "s/\([0-9]\+\.[0-9]\+\)\..*/\1/g")

KDIR	?= /lib/modules/$(KVER)/build
MDIR	?= /lib/modules/$(KVER)
PWD	:= $(shell pwd)

obj-y := $(DRIVER_NAME)/

%.ko:
	$(MAKE) -C $(KDIR) M=$(PWD) $(MODULE_CONFIG)

PHONY += all
all: ${DRIVER_NAME}.ko

PHONY += modules
modules: ${DRIVER_NAME}.ko

PHONY += clean
clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

dkms-config:
	echo Add these parameters in MAKE in dkms.conf.in: $(MODULE_CONFIG)

PHONY += help
help:
	$(MAKE) -C $(KDIR) M=$(PWD) help

PHONY += install
install:
	for i in $(MODULES_INSTALL); do \
	    install -m644 -b -D $(DRIVER_NAME)/$(KVER_MAJ_MIN)/$(DRIVER_SRC_PATH)/$$i ${MDIR}/updates/$(DRIVER_KPATH)/$(DRIVER_NAME)/$$i; \
	done
	depmod -a

PHONY += uninstall
uninstall:
	for i in $(MODULES_INSTALL); do \
	    rm -f $(MDIR)/updates/$(DRIVER_KPATH)/$(DRIVER_NAME)/$$i; \
	done
	if [ -d "$(MDIR)/updates/$(DRIVER_KPATH)/$(DRIVER_NAME)" ]; then \
		if [ -z "$$(ls $(MDIR)/updates/$(DRIVER_KPATH)/$(DRIVER_NAME))" ]; then \
			echo "Remove empty folder $(MDIR)/updates/$(DRIVER_KPATH)/$(DRIVER_NAME)"; \
			rm -rf ${MDIR}/updates/$(DRIVER_KPATH)/$(DRIVER_NAME) ; \
		fi \
	fi
	if [ -d "$(MDIR)/updates/$(DRIVER_KPATH)" ]; then \
		if [ -z "$$(ls $(MDIR)/updates/$(DRIVER_KPATH))" ]; then \
			echo "Remove empty folder ${MDIR}/updates/$(DRIVER_KPATH)"; \
			rm -rf ${MDIR}/updates/$(DRIVER_KPATH) ; \
		fi \
	fi
	depmod -a

endif

.PHONY : $(PHONY)
