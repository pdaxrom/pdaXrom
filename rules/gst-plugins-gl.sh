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

GST_PLUGINS_GL_VERSION=0.10.1
GST_PLUGINS_GL=gst-plugins-gl-${GST_PLUGINS_GL_VERSION}.tar.bz2
GST_PLUGINS_GL_MIRROR=http://gstreamer.freedesktop.org/src/gst-plugins-gl
GST_PLUGINS_GL_DIR=$BUILD_DIR/gst-plugins-gl-${GST_PLUGINS_GL_VERSION}
GST_PLUGINS_GL_ENV="$CROSS_ENV_AC"

build_gst_plugins_gl() {
    test -e "$STATE_DIR/gst_plugins_gl.installed" && return
    banner "Build gst-plugins-gl"
    download $GST_PLUGINS_GL_MIRROR $GST_PLUGINS_GL
    extract $GST_PLUGINS_GL
    apply_patches $GST_PLUGINS_GL_DIR $GST_PLUGINS_GL
    pushd $TOP_DIR
    cd $GST_PLUGINS_GL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GST_PLUGINS_GL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    error "update install"

    popd
    touch "$STATE_DIR/gst_plugins_gl.installed"
}

build_gst_plugins_gl
