# -*-makefile-*-
# $Id: xchain-kernel.make,v 1.16 2003/11/17 03:45:05 mkl Exp $
#
# Copyright (C) 2002, 2003 by Pengutronix e.K., Hildesheim, Germany
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# There are two "groups" of targets here: that ones starting with xchain- are
# only used for the cross chain. The "normal" targets are used for building the
# runtime kernel.
#

ifdef PTXCONF_BUILD_CROSSCHAIN
XCHAIN += xchain-kernel
endif

ifndef PTXCONF_XX_VENDOR_KERNEL
XCHAIN_KERNEL_BUILDDIR	= $(BUILDDIR)/xchain-$(KERNEL)
else
XCHAIN_KERNEL_BUILDDIR	= $(BUILDDIR)/xchain-$(PTXCONF_XX_KERNEL)
endif

# ----------------------------------------------------------------------------
# Patches
# ----------------------------------------------------------------------------

#
# Robert says: Aber dokumentier' das entsprechend...
#
# Well, to build the glibc we need the kernel headers.
# We want to use the kernel plus the selected patches (e.g.: rmk-pxa-ptx)
# But without the ltt (linux trace toolkit) or rtai patches.
#
# The most important thing is, that the glibc and the kernel header
# (against the glibc is built) always stay together, the kernel that
# is running on the system does not matter...
#
# so we pull in the kernel's patches and drop ltt
# (rtai isn't included in kernel flavour)
#
XCHAIN_KERNEL_PATCHES	+= $(addprefix xchain-kernel-, \
	$(call get_option_ext, s/^PTXCONF_KERNEL_[0-9]_[0-9]_[0-9]*_\(.*\)=y/\1/, sed -e 's/_/ /g' -e 's/[0-9]//g' -e 's/ltt//g'))

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-kernel_get: $(STATEDIR)/xchain-kernel.get

$(STATEDIR)/xchain-kernel.get: $(kernel_get)
	@$(call targetinfo, $@)
	@$(call get, $(KERNEL_URL))
	@$(call get_patches, $(KERNEL))
	touch $@

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-kernel_extract: $(STATEDIR)/xchain-kernel.extract

xchain-kernel_extract_deps = \
	$(STATEDIR)/xchain-kernel-base.extract \
	$(addprefix $(STATEDIR)/, $(addsuffix .install, $(XCHAIN_KERNEL_PATCHES)))

$(STATEDIR)/xchain-kernel.extract: $(xchain-kernel_extract_deps)
	@$(call targetinfo, $@)
	touch $@

$(STATEDIR)/xchain-kernel-base.extract: $(STATEDIR)/xchain-kernel.get
	@$(call targetinfo, $@)

ifdef PTXCONF_BUILD_CROSSCHAIN

	@$(call clean, $(XCHAIN_KERNEL_BUILDDIR))
	@$(call extract, $(KERNEL_SOURCE), $(XCHAIN_KERNEL_BUILDDIR))
#
# kernels before 2.4.19 extract to "linux" instead of "linux-version"
#

ifdef PTXCONF_XX_VENDOR_KERNEL
ifneq ($(PTXCONF_XX_KERNEL_DIR), $(PTXCONF_XX_KERNEL))
	mv $(XCHAIN_KERNEL_BUILDDIR)/$(PTXCONF_XX_KERNEL_DIR) $(XCHAIN_KERNEL_BUILDDIR)/$(KERNEL)

endif
else
#ifeq (2.4.17,$(KERNEL_VERSION))
#	mv $(XCHAIN_KERNEL_BUILDDIR)/linux $(XCHAIN_KERNEL_BUILDDIR)/$(KERNEL)
#endif
ifeq (2.4.18,$(KERNEL_VERSION))
	mv $(XCHAIN_KERNEL_BUILDDIR)/linux $(XCHAIN_KERNEL_BUILDDIR)/$(KERNEL)
endif
endif
	mv $(XCHAIN_KERNEL_BUILDDIR)/$(KERNEL)/* $(XCHAIN_KERNEL_BUILDDIR)
	#rmdir $(XCHAIN_KERNEL_BUILDDIR)/$(KERNEL)
	rm -rf $(XCHAIN_KERNEL_BUILDDIR)/$(KERNEL)
# xxx-sashz-xxx
	@$(call patchin, $(KERNEL), $(XCHAIN_KERNEL_BUILDDIR))
endif
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-kernel_prepare: $(STATEDIR)/xchain-kernel.prepare

$(STATEDIR)/xchain-kernel.prepare: $(STATEDIR)/xchain-kernel.extract
	@$(call targetinfo, $@)
ifdef PTXCONF_BUILD_CROSSCHAIN
# fake headers
	make -C $(XCHAIN_KERNEL_BUILDDIR) include/linux/version.h
	touch $(XCHAIN_KERNEL_BUILDDIR)/include/linux/autoconf.h


ifdef PTXCONF_ARM_PROC
	ln -s asm-arm $(XCHAIN_KERNEL_BUILDDIR)/include/asm
	ln -s proc-$(PTXCONF_ARM_PROC) $(XCHAIN_KERNEL_BUILDDIR)/include/asm/proc
	ln -s arch-$(PTXCONF_ARM_ARCH) $(XCHAIN_KERNEL_BUILDDIR)/include/asm/arch
else
	ln -s asm-$(PTXCONF_ARCH) $(XCHAIN_KERNEL_BUILDDIR)/include/asm
endif
endif
	touch $@


# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-kernel_compile: $(STATEDIR)/xchain-kernel.compile

$(STATEDIR)/xchain-kernel.compile:
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-kernel_install: $(STATEDIR)/xchain-kernel.install

$(STATEDIR)/xchain-kernel.install: $(STATEDIR)/xchain-kernel.prepare
	@$(call targetinfo, $@)
ifdef PTXCONF_BUILD_CROSSCHAIN
	@$(call clean, $(CROSS_LIB_DIR)/include/asm)

	if [ -f $(TOPDIR)/config/kernel/$(PTXCONF_KERNEL_CONFIG) ]; then	\
		install -m 644 $(TOPDIR)/config/kernel/$(PTXCONF_KERNEL_CONFIG) \
		$(XCHAIN_KERNEL_BUILDDIR)/.config;				\
	fi

	make -C $(XCHAIN_KERNEL_BUILDDIR) oldconfig $(KERNEL_MAKEVARS)

	make -C $(XCHAIN_KERNEL_BUILDDIR) include/linux/version.h $(KERNEL_MAKEVARS)

	mkdir -p $(CROSS_LIB_DIR)/include

	mkdir -p $(CROSS_LIB_DIR)/include/asm
	
	cp -a $(XCHAIN_KERNEL_BUILDDIR)/include/linux 		$(CROSS_LIB_DIR)/include/linux
	cp -a $(XCHAIN_KERNEL_BUILDDIR)/include/asm/* 		$(CROSS_LIB_DIR)/include/asm
	cp -a $(XCHAIN_KERNEL_BUILDDIR)/include/asm-generic 	$(CROSS_LIB_DIR)/include/asm-generic
endif
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-kernel_targetinstall: $(STATEDIR)/xchain-kernel.targetinstall

$(STATEDIR)/xchain-kernel.targetinstall:
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-kernel_clean: 
	rm -fr $(STATEDIR)/xchain-kernel.*
	rm -fr $(XCHAIN_KERNEL_BUILDDIR)

# vim: syntax=make
