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

GST_PLUGINS_BASE_VERSION=0.10.24
GST_PLUGINS_BASE=gst-plugins-base-${GST_PLUGINS_BASE_VERSION}.tar.bz2
GST_PLUGINS_BASE_MIRROR=http://gstreamer.freedesktop.org/src/gst-plugins-base
GST_PLUGINS_BASE_DIR=$BUILD_DIR/gst-plugins-base-${GST_PLUGINS_BASE_VERSION}
GST_PLUGINS_BASE_ENV="$CROSS_ENV_AC"

build_gst_plugins_base() {
    test -e "$STATE_DIR/gst_plugins_base.installed" && return
    banner "Build gst-plugins-base"
    download $GST_PLUGINS_BASE_MIRROR $GST_PLUGINS_BASE
    extract $GST_PLUGINS_BASE
    apply_patches $GST_PLUGINS_BASE_DIR $GST_PLUGINS_BASE
    pushd $TOP_DIR
    cd $GST_PLUGINS_BASE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GST_PLUGINS_BASE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-gnome_vfs \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gst_plugins_base.installed"
}

build_gst_plugins_base
