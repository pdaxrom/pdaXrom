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

EVIEEXT=evieext-1.0.2.tar.bz2
EVIEEXT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/proto
EVIEEXT_DIR=$BUILD_DIR/evieext-1.0.2
EVIEEXT_ENV=

build_evieext() {
    test -e "$STATE_DIR/evieext-1.0.2" && return
    banner "Build $EVIEEXT"
    download $EVIEEXT_MIRROR $EVIEEXT
    extract $EVIEEXT
    apply_patches $EVIEEXT_DIR $EVIEEXT
    pushd $TOP_DIR
    cd $EVIEEXT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$EVIEEXT_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/evieext-1.0.2"
}

build_evieext
