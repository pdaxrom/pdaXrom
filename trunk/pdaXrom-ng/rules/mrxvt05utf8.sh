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

MRXVT05UTF8_VERSION=svn
MRXVT05UTF8=mrxvt05utf8-${MRXVT05UTF8_VERSION}
MRXVT05UTF8_SVN=http://materm.svn.sourceforge.net/svnroot/materm/mrxvt05utf8
MRXVT05UTF8_DIR=$BUILD_DIR/mrxvt05utf8-${MRXVT05UTF8_VERSION}
MRXVT05UTF8_ENV="$CROSS_ENV_AC"

build_mrxvt05utf8() {
    test -e "$STATE_DIR/mrxvt05utf8.installed" && return
    banner "Build mrxvt05utf8"
    if [ ! -d $MRXVT05UTF8_DIR ]; then
	download_svn $MRXVT05UTF8_SVN $MRXVT05UTF8
	cp -R $SRC_DIR/$MRXVT05UTF8 $MRXVT05UTF8_DIR
	apply_patches $MRXVT05UTF8_DIR $MRXVT05UTF8
    fi
    pushd $TOP_DIR
    cd $MRXVT05UTF8_DIR
    ./bootstrap.sh || error "bootstrap config files"
    (
    eval \
	$CROSS_CONF_ENV \
	$MRXVT05UTF8_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-term=xterm \
	    --enable-xft \
	    --enable-menubar \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    $INSTALL -D -m 644 ${GENERICFS_DIR}/mrxvt/mrxvt.desktop ${ROOTFS_DIR}/usr/share/applications/mrxvt.desktop
    $INSTALL -D -m 644 ${GENERICFS_DIR}/mrxvt/mrxvtrc ${ROOTFS_DIR}/etc/mrxvt/mrxvtrc

    popd
    touch "$STATE_DIR/mrxvt05utf8.installed"
}

build_mrxvt05utf8
