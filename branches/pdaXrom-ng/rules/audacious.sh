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

AUDACIOUS=audacious-1.5.1.tbz2
AUDACIOUS_MIRROR=http://distfiles.atheme.org
AUDACIOUS_DIR=$BUILD_DIR/audacious-1.5.1
AUDACIOUS_ENV="$CROSS_ENV_AC"

build_audacious() {
    test -e "$STATE_DIR/audacious.installed" && return
    banner "Build audacious"
    download $AUDACIOUS_MIRROR $AUDACIOUS
    extract $AUDACIOUS
    apply_patches $AUDACIOUS_DIR $AUDACIOUS
    pushd $TOP_DIR
    cd $AUDACIOUS_DIR
    (
    local AUDACIOUS_CONF=
    case $TARGET_ARCH in
    i686*)
	AUDACIOUS_CONF="--enable-sse2"
	;;
    powerpc*|ppc*)
	AUDACIOUS_CONF="--enable-altivec"
	;;
    *)
	AUDACIOUS_CONF="--disable-sse2 --disable-altivec"
	;;
    esac
    
    eval \
	$CROSS_CONF_ENV \
	$AUDACIOUS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --disable-dbus \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    $AUDACIOUS_CONF \
	    || error
    ) || error "configure"
    
    make $MAKEARGS AR=${CROSS}ar || error

    make $MAKEARGS AR=${CROSS}ar DESTDIR=$AUDACIOUS_DIR/fakeroot install || error
    
    rm -rf fakeroot/usr/include
    rm -rf fakeroot/usr/lib/pkgconfig
    rm -rf fakeroot/usr/share/locale
    rm -rf fakeroot/usr/share/man
    
    cp -R fakeroot/usr $ROOTFS_DIR/ || error

    $STRIP $ROOTFS_DIR/usr/bin/audacious || error
    $STRIP $ROOTFS_DIR/usr/lib/libaudid3tag.so.1.0.0 || error

    popd
    touch "$STATE_DIR/audacious.installed"
}

build_audacious
