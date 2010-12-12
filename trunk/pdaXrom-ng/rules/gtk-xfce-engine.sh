#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

GTK_XFCE_ENGINE_VERSION=2.6.0
GTK_XFCE_ENGINE=gtk-xfce-engine-${GTK_XFCE_ENGINE_VERSION}.tar.bz2
GTK_XFCE_ENGINE_MIRROR=http://archive.xfce.org/src/xfce/gtk-xfce-engine/2.6
GTK_XFCE_ENGINE_DIR=$BUILD_DIR/gtk-xfce-engine-${GTK_XFCE_ENGINE_VERSION}
GTK_XFCE_ENGINE_ENV="$CROSS_ENV_AC"

build_gtk_xfce_engine() {
    test -e "$STATE_DIR/gtk_xfce_engine.installed" && return
    banner "Build gtk-xfce-engine"
    download $GTK_XFCE_ENGINE_MIRROR $GTK_XFCE_ENGINE
    extract $GTK_XFCE_ENGINE
    apply_patches $GTK_XFCE_ENGINE_DIR $GTK_XFCE_ENGINE
    pushd $TOP_DIR
    cd $GTK_XFCE_ENGINE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GTK_XFCE_ENGINE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gtk_xfce_engine.installed"
}

build_gtk_xfce_engine
