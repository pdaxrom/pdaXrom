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

VLC_VERSION=1.1.5
VLC=vlc-${VLC_VERSION}.tar.bz2
VLC_MIRROR=http://download.videolan.org/pub/videolan/vlc/1.1.5
VLC_DIR=$BUILD_DIR/vlc-${VLC_VERSION}
VLC_ENV="$CROSS_ENV_AC"

build_vlc() {
    test -e "$STATE_DIR/vlc.installed" && return
    banner "Build vlc"
    download $VLC_MIRROR $VLC
    extract $VLC
    apply_patches $VLC_DIR $VLC
    pushd $TOP_DIR
    cd $VLC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$VLC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-dvdread \
	    --enable-flac \
	    --enable-xvmc \
	    --disable-pulse \
	    --disable-portaudio \
	    --disable-jack \
	    --enable-skins2 \
	    --enable-qt4 \
	    --disable-lua \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    $INSTALL -D -m 644 share/vlc48x48.png fakeroot/usr/share/pixmaps/vlc.png
    install_fakeroot_finish || error

    install_rootfs_usr_lib ${TARGET_LIB}/libQtCore.so.${QT_X11_OPENSOURCE_SRC_VERSION}
    install_rootfs_usr_lib ${TARGET_LIB}/libQtGui.so.${QT_X11_OPENSOURCE_SRC_VERSION}


    popd
    touch "$STATE_DIR/vlc.installed"
}

build_vlc
