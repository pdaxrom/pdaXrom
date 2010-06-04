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

GST_PLUGINS_UGLY_VERSION=0.10.15
GST_PLUGINS_UGLY=gst-plugins-ugly-${GST_PLUGINS_UGLY_VERSION}.tar.bz2
GST_PLUGINS_UGLY_MIRROR=http://gstreamer.freedesktop.org/src/gst-plugins-ugly
GST_PLUGINS_UGLY_DIR=$BUILD_DIR/gst-plugins-ugly-${GST_PLUGINS_UGLY_VERSION}
GST_PLUGINS_UGLY_ENV="$CROSS_ENV_AC"

build_gst_plugins_ugly() {
    test -e "$STATE_DIR/gst_plugins_ugly.installed" && return
    banner "Build gst-plugins-ugly"
    download $GST_PLUGINS_UGLY_MIRROR $GST_PLUGINS_UGLY
    extract $GST_PLUGINS_UGLY
    apply_patches $GST_PLUGINS_UGLY_DIR $GST_PLUGINS_UGLY
    pushd $TOP_DIR
    cd $GST_PLUGINS_UGLY_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GST_PLUGINS_UGLY_ENV \
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
    touch "$STATE_DIR/gst_plugins_ugly.installed"
}

build_gst_plugins_ugly
