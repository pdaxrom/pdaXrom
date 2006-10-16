# -*-makefile-*-
# $Id: python.make,v 1.5 2003/10/23 15:01:19 mkl Exp $
#
# Copyright (C) 2003 by David R Bacon
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_PYTHON23
PACKAGES += python
endif

#
# Paths and names 
#

#PYTHON_VERSION		= 2.3.4
PYTHON_VERSION		= 2.4.1
PYTHON			= Python-$(PYTHON_VERSION)
PYTHON_SUFFIX		= tar.bz2
PYTHON_URL		= http://www.python.org/ftp/python/$(PYTHON_VERSION)/$(PYTHON).$(PYTHON_SUFFIX)
PYTHON_SOURCE		= $(SRCDIR)/$(PYTHON).$(PYTHON_SUFFIX)
PYTHON_DIR		= $(BUILDDIR)/$(PYTHON)
PYTHON_BUILDDIR		= $(PYTHON_DIR)-build
PYTHON_IPK_TMP_DIR	= $(PYTHON_BUILDDIR)/ipk-tmp
PYTHON_TEMP_DIR		= $(PYTHON_BUILDDIR)/python_ipk
# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

python_get: $(STATEDIR)/python.get

python_get_deps = \
	$(PYTHON_SOURCE)

$(STATEDIR)/python.get: $(python_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PYTHON))
	touch $@

$(PYTHON_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PYTHON_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

python_extract: $(STATEDIR)/python.extract

python_extract_deps = \
	$(STATEDIR)/python.get

$(STATEDIR)/python.extract: $(python_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PYTHON_DIR))
	@$(call extract, $(PYTHON_SOURCE))
	@$(call patchin, $(PYTHON))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

python_prepare: $(STATEDIR)/python.prepare

#
# dependencies
#
python_prepare_deps = \
	$(STATEDIR)/virtual-xchain.install \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/readline.install \
	$(STATEDIR)/python.extract

ifdef PTXCONF_XFREE430
python_prepare_deps += $(STATEDIR)/tk.install
endif

PYTHON_PATH	=  PATH=$(CROSS_PATH)
PYTHON_ENV	=  $(CROSS_ENV)
PYTHON_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"

PYTHON_AUTOCONF	=  --prefix=/usr
PYTHON_AUTOCONF	+= --build=$(GNU_HOST)
PYTHON_AUTOCONF += --host=$(PTXCONF_GNU_TARGET)
PYTHON_AUTOCONF += --target=$(PTXCONF_GNU_TARGET)
PYTHON_AUTOCONF += --disable-debug

PYTHON_AUTOCONF += --enable-shared
PYTHON_AUTOCONF += --disable-static

###PYTHON_AUTOCONF += --enable-unicode=ucs4

PYTHON_AUTOCONF += --with-threads 
PYTHON_AUTOCONF += --with-pymalloc 
PYTHON_AUTOCONF += --with-cyclic-gc

#PYTHON_AUTOCONF += --without-cxx 
#PYTHON_AUTOCONF += --with-signal-module 
#PYTHON_AUTOCONF += --with-wctype-functions
 
PYTHON_MAKEVARS	=  HOSTPYTHON=$(XCHAIN_PYTHON_BUILDDIR)/python
PYTHON_MAKEVARS	+= HOSTPGEN=$(XCHAIN_PYTHON_BUILDDIR)/Parser/pgen
PYTHON_MAKEVARS	+= CROSS_COMPILE=yes
PYTHON_MAKEVARS += CROSS_DIR=$(CROSS_LIB_DIR)

$(STATEDIR)/python.prepare: $(python_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PYTHON_BUILDDIR))
	mkdir -p $(PYTHON_BUILDDIR)
	cd $(PYTHON_BUILDDIR) && \
		$(PYTHON_PATH) $(PYTHON_ENV) \
		$(PYTHON_DIR)/configure $(PYTHON_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

python_compile: $(STATEDIR)/python.compile

python_compile_deps = \
	$(STATEDIR)/xchain-python.compile \
	$(STATEDIR)/python.prepare

$(STATEDIR)/python.compile: $(python_compile_deps)
	@$(call targetinfo, $@)
	$(PYTHON_PATH) $(MAKE) -C $(PYTHON_BUILDDIR) $(PYTHON_MAKEVARS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

python_install: $(STATEDIR)/python.install

$(STATEDIR)/python.install: $(STATEDIR)/python.compile
	@$(call targetinfo, $@)
	$(PYTHON_PATH) $(MAKE) -C $(PYTHON_BUILDDIR) $(PYTHON_MAKEVARS) DESTDIR=$(PYTHON_TEMP_DIR) install
	rm -rf $(CROSS_LIB_DIR)/lib/libpython2.4.so*
	cp -a  $(PYTHON_TEMP_DIR)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(PYTHON_TEMP_DIR)/usr/lib/*.so* $(CROSS_LIB_DIR)/lib
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

python_targetinstall: $(STATEDIR)/python.targetinstall

$(STATEDIR)/python.targetinstall: $(STATEDIR)/python.compile
	@$(call targetinfo, $@)
	rm -rf $(PYTHON_TEMP_DIR)
	$(PYTHON_PATH) $(MAKE) -C $(PYTHON_BUILDDIR) $(PYTHON_MAKEVARS) DESTDIR=$(PYTHON_TEMP_DIR) install
	rm -rf $(PYTHON_TEMP_DIR)/usr/include
	rm -rf $(PYTHON_TEMP_DIR)/usr/man
	rm -rf $(PYTHON_TEMP_DIR)/usr/bin/python
	rm -rf $(PYTHON_TEMP_DIR)/usr/bin/idle
	#rm -rf $(PYTHON_TEMP_DIR)/usr/bin/pydoc
	perl -p -i -e "s/`echo $(PTXCONF_NATIVE_PREFIX) | sed -e '/\//s//\\\\\//g'`/\/usr/g" $(PYTHON_TEMP_DIR)/usr/bin/pydoc
	chmod -R +w $(PYTHON_TEMP_DIR)
	for FILE in `find $(PYTHON_TEMP_DIR)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	#rm -rf $(PYTHON_TEMP_DIR)/usr/lib/python2.4/config
	ln -sf python2.4 $(PYTHON_TEMP_DIR)/usr/bin/python
	for FILE in `find $(PYTHON_TEMP_DIR)/usr/lib -name *.py`; do	\
	    rm -f $$FILE;						\
	done
	for FILE in `find $(PYTHON_TEMP_DIR)/usr/lib -name *.pyo`; do	\
	    rm -f $$FILE;						\
	done
	mkdir -p $(PYTHON_TEMP_DIR)/CONTROL
	echo "Package: python" 				 >$(PYTHON_TEMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_TEMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_TEMP_DIR)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(PYTHON_TEMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_TEMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_TEMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_TEMP_DIR)/CONTROL/control
	echo "Depends: " 				>>$(PYTHON_TEMP_DIR)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(PYTHON_TEMP_DIR)/CONTROL/control

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/bin/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/__future__.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/copy.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/copy_reg.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/ConfigParser.py* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/getopt.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/new.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/os.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/posixpath.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/warnings.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/site.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/stat.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/UserDict.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/binascii.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/struct.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/time.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/readline.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/types.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/libpython*	 			$(PYTHON_IPK_TMP_DIR)/usr/lib/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/bin/python* 				$(PYTHON_IPK_TMP_DIR)/usr/bin/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-core" 			 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: " 				>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Interpreter and core modules">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/codecs.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/encodings 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/gettext.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/locale.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/xdrlib.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/_locale.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/unicodedata.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-codecs" 			 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Codecs, Encodings & i18n Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/bisect.*			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/threading.*		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/Queue.*			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-threading" 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Threading & Synchronization Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/distutils 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-distutils" 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Distribution Utility">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/_csv.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/csv.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/optparse.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/textwrap.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-textutils" 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-io" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Option Parsing, Text Wrapping and Comma-Separated-Value Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/curses 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/_curses.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/_curses_panel.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-curses"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Curses Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/pickle.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/shelve.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/cPickle.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-pickle"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Persistence Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/_socket.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/select.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/termios.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/cStringIO.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/pipes.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/socket.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/tempfile.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/StringIO.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-io"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-math" 	>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Low-Level I/O"	>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/gzip.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/zipfile.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-compression" 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-zlib" 	>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python High Level Compression Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/re.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/sre.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/sre_compile.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/sre_constants* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/sre_parse.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-re"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-stringold" 	>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Regular Expression APIs">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/xmlrpclib.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/SimpleXMLRPCServer.* 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-xmlrpc"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-xml, python-netserver, python-lang">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python XMLRPC Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))


	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/pty.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/tty.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-terminal" 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-io" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Terminal Controlling Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/email 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-email"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-io, python-re">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Email Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/colorsys.* $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/imghdr.* $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/imageop.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/rgbimg.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-image"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Graphical Image Handling">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/resource.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-resource" 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Resource Control Interface">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/cmath.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/math.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/_random.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/random.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-math"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Math Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/hotshot $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/_hotshot.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-hotshot"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Hotshot Profiler">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/nis.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/grp.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/pwd.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/getpass.* $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-unixadmin" 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Unix Administration Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	#rm -rf $(PYTHON_IPK_TMP_DIR);
	#mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	#mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	#cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/gdbm.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	#mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	#echo "Package: python-gdbm"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	#echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	#echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	#echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	#echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	#echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	#echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	#echo "Depends: python-core, libgdbm" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	#echo "Description: Python GNU Database Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	#@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/fcntl.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-fcntl"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python's fcntl Interface">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/base64.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/ftplib.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/gopherlib.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/hmac.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/httplib.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/mimetypes.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/nntplib.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/poplib.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/smtplib.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/telnetlib.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/urllib.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/urllib2.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/urlparse.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-netclient" 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-io, python-mime">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Internet Protocol Clients">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/pprint.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-pprint"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Pretty-Print Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/cgi.* $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/BaseHTTPServer.* $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/SimpleHTTPServer.* $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/SocketServer.* $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-netserver" 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-netclient" 	>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Internet Protocol Servers">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/compiler $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-compiler" 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Compiler Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/syslog.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-syslog"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python's syslog Interface">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/formatter.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/htmlentitydefs.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/htmllib.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/markupbase.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/sgmllib.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/urllib.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/urlparse.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-html"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python HTML Processing">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/readline.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/rlcompleter.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-readline" 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Readline Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/bin/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/bin/pydoc 		$(PYTHON_IPK_TMP_DIR)/usr/bin/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/pydoc.* 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-pydoc"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-lang, python-stringold, python-re">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Interactive Help Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/pyexpat.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/xml 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/xmllib.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-xml"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python basic XML support.">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/mimetools.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/rfc822.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-mime"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-io" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python MIME Handling APIs">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/unittest.* $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-unittest" 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-stringold, python-lang" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Unit Testing Framework">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/strop.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/string.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-stringold" 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Deprecated String APIs">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/py_compile.* $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/compileall.* $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-compile"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Bytecode Compilation Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/commands.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/dircache.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/fnmatch.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/glob.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/popen2.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/shutil.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-shell"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-re" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Shell-Like Functionality">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/mmap.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-mmap" 			 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core, python-io" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Memory-Mapped-File Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR  $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/zlib.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-zlib"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python zlib Support.">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/anydbm.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/dumbdbm.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/whichdb.* 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-db" 			 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python File-Based Database Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/array.so 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/parser.so 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/operator.so 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/_weakref.so 		$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/atexit.* 				$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/code.* 				$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/codeop.* 				$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/dis.* 				$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/inspect.* 				$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/keyword.* 				$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/opcode.* 				$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/repr.* 				$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/token.* 				$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/tokenize.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/traceback.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/linecache.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/weakref.* 				$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-lang"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Low-Level Language Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/crypt.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/md5.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/sha.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-crypto"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Cryptographic and Hashing Support">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/sunau*.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/wave.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/chunk.* 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/linuxaudiodev.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/ossaudiodev.so $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/audioop.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-audio"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python Audio Handling"	>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

ifdef PTXCONF_XFREE430
	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/_tkinter.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-tk 			$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-tk"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python TK/TCL support.">>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))
endif

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/lib-dynload/datetime.so 	$(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/lib-dynload/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-datetime"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python DateTime support."	>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	rm -rf $(PYTHON_IPK_TMP_DIR);
	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL;
	mkdir -p $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;
	cp -dfR $(PYTHON_TEMP_DIR)/usr/lib/python2.4/logging $(PYTHON_IPK_TMP_DIR)/usr/lib/python2.4/;

	mkdir -p $(PYTHON_IPK_TMP_DIR)/CONTROL
	echo "Package: python-logging"	 		 >$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Source: $(PYTHON_URL)" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Priority: optional" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Section: Development" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Version: $(PYTHON_VERSION)" 		>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Depends: python-core" 			>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	echo "Description: Python logging support."	>>$(PYTHON_IPK_TMP_DIR)/CONTROL/control
	@$(call makeipkg, $(PYTHON_IPK_TMP_DIR))

	@$(call makeipkg, $(PYTHON_BUILDDIR)/python_ipk)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

python_clean: 
	rm -rf $(STATEDIR)/python.*
	rm -fr $(PYTHON_DIR)
	rm -fr $(PYTHON_BUILDDIR)

# vim: syntax=make
