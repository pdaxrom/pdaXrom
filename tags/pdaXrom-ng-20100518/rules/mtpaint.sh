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

MTPAINT_VERSION=3.31
MTPAINT=mtpaint-${MTPAINT_VERSION}.tar.bz2
MTPAINT_MIRROR=http://downloads.sourceforge.net/project/mtpaint/mtpaint/${MTPAINT_VERSION}
MTPAINT_DIR=$BUILD_DIR/mtpaint-${MTPAINT_VERSION}
MTPAINT_ENV="$CROSS_ENV_AC"

build_mtpaint() {
    test -e "$STATE_DIR/mtpaint.installed" && return
    banner "Build mtpaint"
    download $MTPAINT_MIRROR $MTPAINT
    extract $MTPAINT
    apply_patches $MTPAINT_DIR $MTPAINT
    pushd $TOP_DIR
    cd $MTPAINT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MTPAINT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    notiff \
	    || error
    ) || error "configure"

    make $MAKEARGS CC=${CROSS}gcc OPT_LDFLAGS="-Wl,-rpath-link,${TARGET_LIB}" || error

    $INSTALL -D -m 755 src/mtpaint $ROOTFS_DIR/usr/bin/mtpaint || error
    $STRIP $ROOTFS_DIR/usr/bin/mtpaint
    $INSTALL -D -m 644 mtpaint.desktop $ROOTFS_DIR/usr/share/applications/mtpaint.desktop || error
    $INSTALL -D -m 644 $GENERICFS_DIR/pixmaps/mtpaint.png $ROOTFS_DIR/usr/share/pixmaps/mtpaint.png || error

    popd
    touch "$STATE_DIR/mtpaint.installed"
}

build_mtpaint
