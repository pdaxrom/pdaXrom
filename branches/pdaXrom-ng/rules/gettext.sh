#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

GETTEXT=gettext-0.17.tar.gz
GETTEXT_MIRROR=http://ftp.gnu.org/pub/gnu/gettext
GETTEXT_DIR=$BUILD_DIR/gettext-0.17
GETTEXT_ENV="$CROSS_ENV_AC \
ac_cv_func_mmap_fixed_mapped=yes \
ac_cv_func_munmap=yes \
ac_cv_func_malloc_0_nonnull=yes \
ac_cv_func_strnlen_working=yes \
am_cv_func_iconv_works=yes \
gl_cv_func_wcwidth_works=yes \
gt_cv_func_printf_posix=yes \
gt_cv_int_divbyzero_sigfpe=yes \
"

if [ "${TARGET_ARCH/-*}" = "x86_64" -o "${TARGET_ARCH/-*}" = "amd64" ]; then
    GETTEXT_ENV="CFLAGS='-O2 -D_FORTIFY_SOURCE=0' $GETTEXT_ENV"
fi

build_gettext() {
    test -e "$STATE_DIR/gettext.installed" && return
    banner "Build gettext"
    download $GETTEXT_MIRROR $GETTEXT
    extract $GETTEXT
    apply_patches $GETTEXT_DIR $GETTEXT
    pushd $TOP_DIR
    cd $GETTEXT_DIR
    (
#	$CROSS_CONF_ENV
    eval \
	$GETTEXT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-java \
	    --disable-native-java \
	    --disable-csharp \
	    --with-libncurses-prefix=$TARGET_BIN_DIR \
	    --with-libglib-2.0-prefix=$TARGET_BIN_DIR \
	    --with-libxml2-prefix=$TARGET_BIN_DIR \
	    --without-libcroco-0.6-prefix \
	    || error
    ) || error "configure"

    find . -name libtool | while read f; do
	sed -i -e 's:add_dir="-L$libdir"::g' $f
    done
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 gettext-tools/gnulib-lib/.libs/libgettextlib-0.17.so $ROOTFS_DIR/usr/lib/libgettextlib-0.17.so || error
    ln -sf libgettextlib-0.17.so $ROOTFS_DIR/usr/lib/libgettextlib.so
    $STRIP $ROOTFS_DIR/usr/lib/libgettextlib-0.17.so || error
    
    $INSTALL -D -m 644 gettext-runtime/libasprintf/.libs/libasprintf.so.0.0.0 $ROOTFS_DIR/usr/lib/libasprintf.so.0.0.0 || error
    ln -sf libasprintf.so.0.0.0 $ROOTFS_DIR/usr/lib/libasprintf.so.0
    ln -sf libasprintf.so.0.0.0 $ROOTFS_DIR/usr/lib/libasprintf.so
    $STRIP $ROOTFS_DIR/usr/lib/libasprintf.so.0.0.0 || error

    $INSTALL -D -m 644 gettext-tools/libgettextpo/.libs/libgettextpo.so.0.4.0 $ROOTFS_DIR/usr/lib/libgettextpo.so.0.4.0 || error
    ln -sf libgettextpo.so.0.4.0 $ROOTFS_DIR/usr/lib/libgettextpo.so.0
    ln -sf libgettextpo.so.0.4.0 $ROOTFS_DIR/usr/lib/libgettextpo.so
    $STRIP $ROOTFS_DIR/usr/lib/libgettextpo.so.0.4.0 || error
    
    $INSTALL -D -m 644 gettext-tools/src/.libs/libgettextsrc-0.17.so $ROOTFS_DIR/usr/lib/libgettextsrc-0.17.so || error
    ln -sf libgettextsrc-0.17.so $ROOTFS_DIR/usr/lib/libgettextsrc.so
    $STRIP $ROOTFS_DIR/usr/lib/libgettextsrc-0.17.so || error

    if [ -e gettext-runtime/intl/.libs/libintl.so.8.0.2 ]; then
	$INSTALL -D -m 644 gettext-runtime/intl/.libs/libintl.so.8.0.2 $ROOTFS_DIR/usr/lib/libintl.so.8.0.2 || error
	ln -sf libintl.so.8.0.2 $ROOTFS_DIR/usr/lib/libintl.so.8 || error
        ln -sf libintl.so.8.0.2 $ROOTFS_DIR/usr/lib/libintl.so || error
        $STRIP $ROOTFS_DIR/usr/lib/libintl.so.8.0.2 || error
    fi

    popd
    touch "$STATE_DIR/gettext.installed"
}

build_gettext
