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

UNZIP=unzip552.tar.gz
UNZIP_MIRROR=ftp://tug.ctan.org/tex-archive/tools/zip/info-zip/src
UNZIP_DIR=$BUILD_DIR/unzip-5.52
UNZIP_ENV="$CROSS_ENV_AC"

build_unzip() {
    test -e "$STATE_DIR/unzip.installed" && return
    banner "Build unzip"
    download $UNZIP_MIRROR $UNZIP
    extract $UNZIP
    apply_patches $UNZIP_DIR $UNZIP
    pushd $TOP_DIR
    cd $UNZIP_DIR
    
    make $MAKEARGS \
	-f unix/Makefile \
	CC=${CROSS}gcc \
	CPP=${CROSS}cpp \
	AS=${CROSS}as \
	CF='-O2 -I. -DUNIX' \
	generic \
	|| error

    $INSTALL -D -m 755 unzip $ROOTFS_DIR/usr/bin/unzip || error
    $STRIP $ROOTFS_DIR/usr/bin/unzip
    ln -sf unzip $ROOTFS_DIR/usr/bin/zipinfo || error

    popd
    touch "$STATE_DIR/unzip.installed"
}

build_unzip
