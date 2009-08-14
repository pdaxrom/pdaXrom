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

LIBVORBIS_VERSION=1.2.0
LIBVORBIS=libvorbis-${LIBVORBIS_VERSION}.tar.gz
LIBVORBIS_MIRROR=http://downloads.xiph.org/releases/vorbis
LIBVORBIS_DIR=$BUILD_DIR/libvorbis-${LIBVORBIS_VERSION}
LIBVORBIS_ENV="$CROSS_ENV_AC"

build_libvorbis() {
    test -e "$STATE_DIR/libvorbis.installed" && return
    banner "Build libvorbis"
    download $LIBVORBIS_MIRROR $LIBVORBIS
    extract $LIBVORBIS
    apply_patches $LIBVORBIS_DIR $LIBVORBIS
    pushd $TOP_DIR
    cd $LIBVORBIS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBVORBIS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    install_rootfs_usr_lib lib/.libs/libvorbis.so.0.4.0
    install_rootfs_usr_lib lib/.libs/libvorbisenc.so.2.0.3
    install_rootfs_usr_lib lib/.libs/libvorbisfile.so.3.2.0

    popd
    touch "$STATE_DIR/libvorbis.installed"
}

build_libvorbis
