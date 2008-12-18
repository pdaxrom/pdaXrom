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

XDIALOG=Xdialog-2.3.1.tar.bz2
XDIALOG_MIRROR=http://xdialog.free.fr
XDIALOG_DIR=$BUILD_DIR/Xdialog-2.3.1
XDIALOG_ENV="$CROSS_ENV_AC"

build_Xdialog() {
    test -e "$STATE_DIR/Xdialog.installed" && return
    banner "Build Xdialog"
    download $XDIALOG_MIRROR $XDIALOG
    extract $XDIALOG
    apply_patches $XDIALOG_DIR $XDIALOG
    pushd $TOP_DIR
    cd $XDIALOG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XDIALOG_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --with-gtk2 \
	    --disable-gtktest
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 src/Xdialog $ROOTFS_DIR/usr/bin/Xdialog || error
    $STRIP $ROOTFS_DIR/usr/bin/Xdialog

    popd
    touch "$STATE_DIR/Xdialog.installed"
}

build_Xdialog
