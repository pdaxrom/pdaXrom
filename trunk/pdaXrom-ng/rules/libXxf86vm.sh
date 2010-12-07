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

LIBXXF86VM_VERSION=1.1.1
LIBXXF86VM=libXxf86vm-${LIBXXF86VM_VERSION}.tar.bz2
LIBXXF86VM_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXXF86VM_DIR=$BUILD_DIR/libXxf86vm-${LIBXXF86VM_VERSION}
LIBXXF86VM_ENV=

build_libXxf86vm() {
    test -e "$STATE_DIR/libXxf86vm-${LIBXXF86VM_VERSION}" && return
    banner "Build $LIBXXF86VM"
    download $LIBXXF86VM_MIRROR $LIBXXF86VM
    extract $LIBXXF86VM
    apply_patches $LIBXXF86VM_DIR $LIBXXF86VM
    pushd $TOP_DIR
    cd $LIBXXF86VM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXXF86VM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXxf86vm-${LIBXXF86VM_VERSION}"
}

build_libXxf86vm
