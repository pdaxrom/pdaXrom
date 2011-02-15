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

LIBGSF_VERSION=1.14.18
LIBGSF=libgsf-${LIBGSF_VERSION}.tar.bz2
LIBGSF_MIRROR=http://ftp.gnome.org/pub/gnome/sources/libgsf/1.14
LIBGSF_DIR=$BUILD_DIR/libgsf-${LIBGSF_VERSION}
LIBGSF_ENV="$CROSS_ENV_AC"

build_libgsf() {
    test -e "$STATE_DIR/libgsf.installed" && return
    banner "Build libgsf"
    download $LIBGSF_MIRROR $LIBGSF
    extract $LIBGSF
    apply_patches $LIBGSF_DIR $LIBGSF
    pushd $TOP_DIR
    cd $LIBGSF_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBGSF_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --without-python \
	    --without-gnome-vfs \
	    --without-bonobo \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libgsf.installed"
}

build_libgsf
