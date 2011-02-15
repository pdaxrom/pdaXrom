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

GST_PLUGINS_GOOD_VERSION=0.10.23
GST_PLUGINS_GOOD=gst-plugins-good-${GST_PLUGINS_GOOD_VERSION}.tar.bz2
GST_PLUGINS_GOOD_MIRROR=http://gstreamer.freedesktop.org/src/gst-plugins-good
GST_PLUGINS_GOOD_DIR=$BUILD_DIR/gst-plugins-good-${GST_PLUGINS_GOOD_VERSION}
GST_PLUGINS_GOOD_ENV="$CROSS_ENV_AC"

build_gst_plugins_good() {
    test -e "$STATE_DIR/gst_plugins_good.installed" && return
    banner "Build gst-plugins-good"
    download $GST_PLUGINS_GOOD_MIRROR $GST_PLUGINS_GOOD
    extract $GST_PLUGINS_GOOD
    apply_patches $GST_PLUGINS_GOOD_DIR $GST_PLUGINS_GOOD
    pushd $TOP_DIR
    cd $GST_PLUGINS_GOOD_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GST_PLUGINS_GOOD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-aalib \
	    --disable-libcaca \
	    --disable-esd \
	    --disable-pulse \
	    --disable-osx_audio \
	    --disable-osx_video \
	    --disable-sunaudio \
	    --disable-shout2 \
	    --disable-schemas-install \
	    --disable-gconftool \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish

    popd
    touch "$STATE_DIR/gst_plugins_good.installed"
}

build_gst_plugins_good
