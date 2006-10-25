# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2006 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_SAMBA
PACKAGES += samba
endif

#
# Paths and names
#
SAMBA_VENDOR_VERSION	= 1
SAMBA_VERSION		= 3.0.23c
SAMBA			= samba-$(SAMBA_VERSION)
SAMBA_SUFFIX		= tar.gz
SAMBA_URL		= http://us1.samba.org/samba/ftp/$(SAMBA).$(SAMBA_SUFFIX)
SAMBA_SOURCE		= $(SRCDIR)/$(SAMBA).$(SAMBA_SUFFIX)
SAMBA_DIR		= $(BUILDDIR)/$(SAMBA)
SAMBA_IPKG_TMP		= $(SAMBA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

samba_get: $(STATEDIR)/samba.get

samba_get_deps = $(SAMBA_SOURCE)

$(STATEDIR)/samba.get: $(samba_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SAMBA))
	touch $@

$(SAMBA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SAMBA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

samba_extract: $(STATEDIR)/samba.extract

samba_extract_deps = $(STATEDIR)/samba.get

$(STATEDIR)/samba.extract: $(samba_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SAMBA_DIR))
	@$(call extract, $(SAMBA_SOURCE))
	@$(call patchin, $(SAMBA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

samba_prepare: $(STATEDIR)/samba.prepare

#
# dependencies
#
samba_prepare_deps = \
	$(STATEDIR)/samba.extract \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_CUPS
samba_prepare_deps += $(STATEDIR)/cups.install
endif

SAMBA_PATH	=  PATH=$(CROSS_PATH)
SAMBA_ENV 	=  $(CROSS_ENV)
#SAMBA_ENV	+=
SAMBA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SAMBA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

ifeq	(2.3.2,$(GLIBC_VERSION))
SAMBA_ENV	+= linux_getgrouplist_ok=yes
else
SAMBA_ENV	+= linux_getgrouplist_ok=no
endif

SAMBA_ENV += samba_cv_HAVE_GETTIMEOFDAY_TZ=yes
SAMBA_ENV += samba_cv_HAVE_BROKEN_FCNTL64_LOCKS=no
SAMBA_ENV += samba_cv_HAVE_BROKEN_GETGROUPS=no
SAMBA_ENV += samba_cv_HAVE_BROKEN_READDIR=no
SAMBA_ENV += samba_cv_HAVE_C99_VSNPRINTF=yes
SAMBA_ENV += samba_cv_HAVE_DEV64_T=no
SAMBA_ENV += samba_cv_HAVE_DEVICE_MAJOR_FN=yes
SAMBA_ENV += samba_cv_HAVE_DEVICE_MINOR_FN=yes
SAMBA_ENV += samba_cv_HAVE_FCNTL_LOCK=yes
SAMBA_ENV += samba_cv_HAVE_FTRUNCATE_EXTEND=yes
SAMBA_ENV += samba_cv_HAVE_IFACE_AIX=no
SAMBA_ENV += samba_cv_HAVE_IFACE_IFCONF=yes
SAMBA_ENV += samba_cv_HAVE_INO64_T=no
SAMBA_ENV += samba_cv_HAVE_KERNEL_CHANGE_NOTIFY=yes
SAMBA_ENV += samba_cv_HAVE_KERNEL_OPLOCKS_LINUX=yes
SAMBA_ENV += samba_cv_HAVE_KERNEL_SHARE_MODES=yes
SAMBA_ENV += samba_cv_HAVE_MAKEDEV_FN=yes
SAMBA_ENV += samba_cv_HAVE_MMAP=yes
SAMBA_ENV += samba_cv_HAVE_OFF64_T=no
SAMBA_ENV += samba_cv_HAVE_ROOT=no
SAMBA_ENV += samba_cv_HAVE_SECURE_MKSTEMP=yes
SAMBA_ENV += samba_cv_HAVE_STRUCT_FLOCK64=yes
SAMBA_ENV += samba_cv_HAVE_TRUNCATED_SALT=no
SAMBA_ENV += samba_cv_HAVE_UNSIGNED_CHAR=no
SAMBA_ENV += samba_cv_REPLACE_INET_NTOA=no
SAMBA_ENV += samba_cv_SIZEOF_INO_T=yes
SAMBA_ENV += samba_cv_SIZEOF_OFF_T=yes
SAMBA_ENV += samba_cv_USE_SETRESUID=yes
SAMBA_ENV += samba_cv_HAVE_BROKEN_READDIR_NAME=no
#ifdef PTXCONF_ARCH_ARM
SAMBA_ENV += fu_cv_sys_stat_statvfs64=no
#else
#SAMBA_ENV += fu_cv_sys_stat_statvfs64=yes
#endif
SAMBA_ENV += samba_cv_HAVE_MAKEDEV=yes
SAMBA_ENV += samba_cv_HAVE_WORKING_AF_LOCAL=yes
SAMBA_ENV += samba_cv_HAVE_Werror=yes
SAMBA_ENV += samba_cv_REALPATH_TAKES_NULL=no
SAMBA_ENV += samba_cv_SIZEOF_DEV_T=yes
SAMBA_ENV += samba_cv_have_longlong=yes
SAMBA_ENV += samba_cv_have_setresgid=yes
SAMBA_ENV += samba_cv_have_setresuid=yes

#
# autoconf
#
SAMBA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-static \
	--enable-shared \
	--localstatedir=/var \
	--with-configdir=/etc/samba \
	--with-privatedir=/etc/samba \
	--with-fhs \
	--with-quotas \
	--with-smbmount \
	--with-syslog \
	--with-utmp \
	--with-swatdir=/usr/share/swat \
	--with-libsmbsharemodes \
	--with-libsmbclient 

#	--with-shared-modules=idmap_rid 

ifndef PTXCONF_CUPS
SAMBA_AUTOCONF += --disable-cups
endif

ifdef PTXCONF_XFREE430
SAMBA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SAMBA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/samba.prepare: $(samba_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SAMBA_DIR)/config.cache)
	cd $(SAMBA_DIR)/source && \
		$(SAMBA_PATH) $(SAMBA_ENV) \
		./configure $(SAMBA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

samba_compile: $(STATEDIR)/samba.compile

samba_compile_deps = $(STATEDIR)/samba.prepare

$(STATEDIR)/samba.compile: $(samba_compile_deps)
	@$(call targetinfo, $@)
	$(SAMBA_PATH) $(MAKE) -C $(SAMBA_DIR)/source
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

samba_install: $(STATEDIR)/samba.install

$(STATEDIR)/samba.install: $(STATEDIR)/samba.compile
	@$(call targetinfo, $@)
	rm -rf $(SAMBA_IPKG_TMP)
	$(SAMBA_PATH) $(MAKE) -C $(SAMBA_DIR) DESTDIR=$(SAMBA_IPKG_TMP) install
	@$(call copyincludes, $(SAMBA_IPKG_TMP))
	@$(call copylibraries,$(SAMBA_IPKG_TMP))
	@$(call copymiscfiles,$(SAMBA_IPKG_TMP))
	rm -rf $(SAMBA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

samba_targetinstall: $(STATEDIR)/samba.targetinstall

samba_targetinstall_deps = $(STATEDIR)/samba.compile

ifdef PTXCONF_CUPS
samba_targetinstall_deps += $(STATEDIR)/cups.targetinstall
endif

SAMBA_DEPLIST = 

$(STATEDIR)/samba.targetinstall: $(samba_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SAMBA_PATH) $(MAKE) -C $(SAMBA_DIR)/source DESTDIR=$(SAMBA_IPKG_TMP) install

	PATH=$(CROSS_PATH) 						\
	FEEDDIR=$(FEEDDIR) 						\
	STRIP=$(PTXCONF_GNU_TARGET)-strip 				\
	VERSION=$(SAMBA_VERSION)-$(SAMBA_VENDOR_VERSION)	 	\
	ARCH=$(SHORT_TARGET) 						\
	MKIPKG=$(TOPDIR)/scripts/bin/mkipkg 				\
	$(TOPDIR)/scripts/bin/make-locale-ipks.sh samba $(SAMBA_IPKG_TMP)

	@$(call removedevfiles, $(SAMBA_IPKG_TMP))
	@$(call stripfiles, $(SAMBA_IPKG_TMP))
	mkdir -p $(SAMBA_IPKG_TMP)/CONTROL
	echo "Package: samba" 								 >$(SAMBA_IPKG_TMP)/CONTROL/control
	echo "Source: $(SAMBA_URL)"							>>$(SAMBA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(SAMBA_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(SAMBA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(SAMBA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(SAMBA_IPKG_TMP)/CONTROL/control
	echo "Version: $(SAMBA_VERSION)-$(SAMBA_VENDOR_VERSION)" 			>>$(SAMBA_IPKG_TMP)/CONTROL/control
	echo "Depends: $(SAMBA_DEPLIST)" 						>>$(SAMBA_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(SAMBA_IPKG_TMP)/CONTROL/control
	@$(call makeipkg, $(SAMBA_IPKG_TMP))
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SAMBA_INSTALL
ROMPACKAGES += $(STATEDIR)/samba.imageinstall
endif

samba_imageinstall_deps = $(STATEDIR)/samba.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/samba.imageinstall: $(samba_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install samba
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

samba_clean:
	rm -rf $(STATEDIR)/samba.*
	rm -rf $(SAMBA_DIR)

# vim: syntax=make
