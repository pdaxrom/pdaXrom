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

GPICVIEW_VERSION=0.2.1
GPICVIEW=gpicview-${GPICVIEW_VERSION}.tar.gz
GPICVIEW_MIRROR=http://downloads.sourceforge.net/project/lxde/GPicView%20%28image%20Viewer%29/GPicView%200.2.1
GPICVIEW_DIR=$BUILD_DIR/gpicview-${GPICVIEW_VERSION}
GPICVIEW_ENV="$CROSS_ENV_AC"

build_gpicview() {
    test -e "$STATE_DIR/gpicview.installed" && return
    banner "Build gpicview"
    download $GPICVIEW_MIRROR $GPICVIEW
    extract $GPICVIEW
    apply_patches $GPICVIEW_DIR $GPICVIEW
    pushd $TOP_DIR
    cd $GPICVIEW_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GPICVIEW_ENV \
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
    touch "$STATE_DIR/gpicview.installed"
}

build_gpicview
