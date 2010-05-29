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

ZIP=zip${ZIP_VERSION}.tar.gz
ZIP_VERSION=232
ZIP_MIRROR=ftp://tug.ctan.org/tex-archive/tools/zip/info-zip/src
ZIP_DIR=$BUILD_DIR/zip-${ZIP_VERSION}
ZIP_ENV="$CROSS_ENV_AC"

build_zip() {
    test -e "$STATE_DIR/zip.installed" && return
    banner "Build zip"
    download $ZIP_MIRROR $ZIP
    extract $ZIP
    apply_patches $ZIP_DIR $ZIP
    pushd $TOP_DIR
    cd $ZIP_DIR
    
    CC=${CROSS}gcc \
    CPP=${CROSS}cpp \
    make $MAKEARGS \
	-f unix/Makefile \
	CC=${CROSS}gcc \
	CPP=${CROSS}cpp \
	CFLAGS='-I. -DUNIX -O2' \
	INSTALL=$INSTALL \
	BINFLAGS=0755 \
	INSTALL_D='install -d' \
	BINDIR=/usr/bin \
	generic \
	|| error

    $INSTALL -D -m 755 zip $ROOTFS_DIR/usr/bin/zip || error
    $STRIP $ROOTFS_DIR/usr/bin/zip

    popd
    touch "$STATE_DIR/zip.installed"
}

build_zip
