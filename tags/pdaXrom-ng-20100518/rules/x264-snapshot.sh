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

X264_SNAPSHOT_VERSION=20091217-2245
X264_SNAPSHOT=x264-snapshot-${X264_SNAPSHOT_VERSION}.tar.bz2
X264_SNAPSHOT_MIRROR=ftp://ftp.videolan.org/pub/videolan/x264/snapshots
X264_SNAPSHOT_DIR=$BUILD_DIR/x264-snapshot-${X264_SNAPSHOT_VERSION}
X264_SNAPSHOT_ENV="$CROSS_ENV_AC"

build_x264_snapshot() {
    test -e "$STATE_DIR/x264_snapshot.installed" && return
    banner "Build x264-snapshot"
    download $X264_SNAPSHOT_MIRROR $X264_SNAPSHOT
    extract $X264_SNAPSHOT
    apply_patches $X264_SNAPSHOT_DIR $X264_SNAPSHOT
    pushd $TOP_DIR
    cd $X264_SNAPSHOT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$X264_SNAPSHOT_ENV \
	./configure --host=$TARGET_ARCH \
	    --enable-pic \
	    --enable-shared \
	    --cross-prefix=${CROSS} \
	    || error
    ) || error "configure"

    make $MAKEARGS prefix=/usr || error

    install_sysroot_files prefix=/usr || error

    install_fakeroot_init prefix=/usr

    rm -rf fakeroot/usr/bin

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/x264_snapshot.installed"
}

build_x264_snapshot
