#
# host packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_LZMA=lzma457.tar.bz2
HOST_LZMA_MIRROR=ftp://ftp.slax.org/source/slax/sqlzma
HOST_LZMA_DIR=$HOST_BUILD_DIR/lzma457
HOST_LZMA_ENV=

build_host_lzma() {
    test -e "$STATE_DIR/host_lzma.installed" && return
    banner "Build host-lzma"
    download $HOST_LZMA_MIRROR $HOST_LZMA
    mkdir $HOST_LZMA_DIR
    pushd $TOP_DIR
    cd $HOST_LZMA_DIR
    tar jxf $SRC_DIR/$HOST_LZMA
    apply_patches $HOST_LZMA_DIR $HOST_LZMA

    make Sqlzma=$HOST_LZMA_DIR -C C/Compress/Lzma -f sqlzma.mk || error
    make Sqlzma=$HOST_LZMA_DIR -C CPP/7zip/Compress/LZMA_Alone -f sqlzma.mk || error
    
    popd
    touch "$STATE_DIR/host_lzma.installed"
}

build_host_lzma
