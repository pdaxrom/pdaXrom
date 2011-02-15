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

GTKDIALOG_VERSION=0.7.20
GTKDIALOG=gtkdialog-${GTKDIALOG_VERSION}.tar.gz
GTKDIALOG_MIRROR=ftp://linux.pte.hu/pub/gtkdialog
GTKDIALOG_DIR=$BUILD_DIR/gtkdialog-${GTKDIALOG_VERSION}
GTKDIALOG_ENV="$CROSS_ENV_AC"

build_gtkdialog() {
    test -e "$STATE_DIR/gtkdialog.installed" && return
    banner "Build gtkdialog"
    download $GTKDIALOG_MIRROR $GTKDIALOG
    extract $GTKDIALOG
    apply_patches $GTKDIALOG_DIR $GTKDIALOG
    pushd $TOP_DIR
    cd $GTKDIALOG_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GTKDIALOG_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gtkdialog.installed"
}

build_gtkdialog
