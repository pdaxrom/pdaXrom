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

UNRAR=unrarsrc-3.8.5.tar.gz
UNRAR_MIRROR=http://www.rarlab.com/rar
UNRAR_DIR=$BUILD_DIR/unrar
UNRAR_ENV="$CROSS_ENV_AC"

build_unrar() {
    test -e "$STATE_DIR/unrar.installed" && return
    banner "Build unrar"
    download $UNRAR_MIRROR $UNRAR
    extract $UNRAR
    apply_patches $UNRAR_DIR $UNRAR
    pushd $TOP_DIR
    cd $UNRAR_DIR
    
    make $MAKEARGS \
	CXX=${CROSS}g++ \
	CC=${CROSS}gcc \
	STRIP=${CROSS}strip \
	CXXFLAGS='-O2' \
	-f makefile.unix \
	|| error

    $INSTALL -D -m 755 unrar $ROOTFS_DIR/usr/bin/unrar || error
    $STRIP $ROOTFS_DIR/usr/bin/unrar

    popd
    touch "$STATE_DIR/unrar.installed"
}

build_unrar
