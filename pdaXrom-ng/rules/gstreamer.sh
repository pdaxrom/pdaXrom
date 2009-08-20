#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

GSTREAMER_VERSION=0.10.24
GSTREAMER=gstreamer-${GSTREAMER_VERSION}.tar.bz2
GSTREAMER_MIRROR=http://gstreamer.freedesktop.org/src/gstreamer
GSTREAMER_DIR=$BUILD_DIR/gstreamer-${GSTREAMER_VERSION}
GSTREAMER_ENV="$CROSS_ENV_AC"

build_gstreamer() {
    test -e "$STATE_DIR/gstreamer.installed" && return
    banner "Build gstreamer"
    download $GSTREAMER_MIRROR $GSTREAMER
    extract $GSTREAMER
    apply_patches $GSTREAMER_DIR $GSTREAMER
    pushd $TOP_DIR
    cd $GSTREAMER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GSTREAMER_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --localstatedir=/var \
	    --disable-debug \
	    --disable-gst-debug \
	    --disable-trace \
	    --disable-alloc-trace \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init || error
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gstreamer.installed"
}

build_gstreamer
