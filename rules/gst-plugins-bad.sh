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

GST_PLUGINS_BAD_VERSION=0.10.13
GST_PLUGINS_BAD=gst-plugins-bad-${GST_PLUGINS_BAD_VERSION}.tar.bz2
GST_PLUGINS_BAD_MIRROR=http://gstreamer.freedesktop.org/src/gst-plugins-bad
GST_PLUGINS_BAD_DIR=$BUILD_DIR/gst-plugins-bad-${GST_PLUGINS_BAD_VERSION}
GST_PLUGINS_BAD_ENV="$CROSS_ENV_AC"

build_gst_plugins_bad() {
    test -e "$STATE_DIR/gst_plugins_bad.installed" && return
    banner "Build gst-plugins-bad"
    download $GST_PLUGINS_BAD_MIRROR $GST_PLUGINS_BAD
    extract $GST_PLUGINS_BAD
    apply_patches $GST_PLUGINS_BAD_DIR $GST_PLUGINS_BAD
    pushd $TOP_DIR
    cd $GST_PLUGINS_BAD_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GST_PLUGINS_BAD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gst_plugins_bad.installed"
}

build_gst_plugins_bad
