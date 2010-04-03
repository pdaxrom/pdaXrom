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

LINPHONE_VERSION=3.1.2
LINPHONE=linphone-${LINPHONE_VERSION}.tar.gz
LINPHONE_MIRROR=http://ftp.twaren.net/Unix/NonGNU/linphone/stable/sources
LINPHONE_DIR=$BUILD_DIR/linphone-${LINPHONE_VERSION}
LINPHONE_ENV="$CROSS_ENV_AC"

build_linphone() {
    test -e "$STATE_DIR/linphone.installed" && return
    banner "Build linphone"
    download $LINPHONE_MIRROR $LINPHONE
    extract $LINPHONE
    apply_patches $LINPHONE_DIR $LINPHONE
    pushd $TOP_DIR
    cd $LINPHONE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LINPHONE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/linphone-${LINPHONE_VERSION} \
	    --with-sdl=$TARGET_BIN_DIR \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make $MAKEARGS DESTDIR=$PWD/fakeroot install || error

    rm -rf fakeroot/usr/include fakeroot/usr/lib/pkgconfig fakeroot/usr/share/gnome fakeroot/usr/share/locale fakeroot/usr/share/man
    rm -f fakeroot/usr/lib/*.*a

    $STRIP fakeroot/usr/bin/* fakeroot/usr/lib/* fakeroot/usr/lib/linphone-${LINPHONE_VERSION}/*

    cp -a fakeroot/usr $ROOTFS_DIR/ || error

    popd
    touch "$STATE_DIR/linphone.installed"
}

build_linphone
