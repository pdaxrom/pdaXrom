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

ARORA_VERSION=0.10.2
ARORA=arora-${ARORA_VERSION}.tar.gz
ARORA_MIRROR=http://arora.googlecode.com/files
ARORA_DIR=$BUILD_DIR/arora-${ARORA_VERSION}
ARORA_ENV="$CROSS_ENV_AC"

build_arora() {
    test -e "$STATE_DIR/arora.installed" && return
    banner "Build arora"
    download $ARORA_MIRROR $ARORA
    extract $ARORA
    apply_patches $ARORA_DIR $ARORA
    pushd $TOP_DIR
    cd $ARORA_DIR

    sed -i -e 's|/usr/local|/usr|' install.pri

    qmake || error "qmake"

    make $MAKEARGS || error "build"

    install_fakeroot_init INSTALL_ROOT=${ARORA_DIR}/fakeroot
    install_fakeroot_finish || error

    for f in libQtWebKit libphonon libQtDBus libQtXml libQtScript libQtGui; do
	local l=`cat ${QT_X11_OPENSOURCE_SRC_DIR}/lib/${f}.prl | grep "QMAKE_PRL_TARGET" | awk '{print $3}'`
	install_rootfs_usr_lib ${QT_X11_OPENSOURCE_SRC_DIR}/lib/${l}
    done

    popd
    touch "$STATE_DIR/arora.installed"
}

build_arora
