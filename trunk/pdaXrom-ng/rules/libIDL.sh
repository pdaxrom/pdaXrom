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

LIBIDL=libIDL-0.8.12.tar.bz2
LIBIDL_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/libIDL/0.8
LIBIDL_DIR=$BUILD_DIR/libIDL-0.8.12
LIBIDL_ENV="$CROSS_ENV_AC libIDL_cv_long_long_format=ll"

build_libIDL() {
    test -e "$STATE_DIR/libIDL.installed" && return
    banner "Build libIDL"
    download $LIBIDL_MIRROR $LIBIDL
    extract $LIBIDL
    apply_patches $LIBIDL_DIR $LIBIDL
    pushd $TOP_DIR
    cd $LIBIDL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBIDL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-foo \
	    --disable-shared
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    ln -sf $TARGET_BIN_DIR/bin/libIDL-config-2 $HOST_BIN_DIR/bin/ || error

    popd
    touch "$STATE_DIR/libIDL.installed"
}

build_libIDL
