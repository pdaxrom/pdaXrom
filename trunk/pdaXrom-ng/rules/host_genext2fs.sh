HOST_GENEXT2FS=genext2fs-1.4.1.tar.gz
HOST_GENEXT2FS_MIRROR=http://downloads.sourceforge.net/genext2fs
HOST_GENEXT2FS_DIR=$BUILD_DIR/genext2fs-1.4.1

build_host_genext2fs() {
    test -e "$STATE_DIR/host_genext2fs" && return
    banner "Build $HOST_GENEXT2FS"
    download $HOST_GENEXT2FS_MIRROR $HOST_GENEXT2FS
    extract $HOST_GENEXT2FS
    apply_patches $HOST_GENEXT2FS_DIR $HOST_GENEXT2FS
    pushd $TOP_DIR
    cd $HOST_GENEXT2FS_DIR
    ./configure --prefix=$HOST_BIN_DIR || error
    make || error
    make install
    popd
    touch "$STATE_DIR/host_genext2fs"
}

build_host_genext2fs
