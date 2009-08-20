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

AUDACIOUS_VERSION=1.5.1
AUDACIOUS=audacious-${AUDACIOUS_VERSION}.tgz
AUDACIOUS_MIRROR=http://distfiles.atheme.org
AUDACIOUS_DIR=$BUILD_DIR/audacious-${AUDACIOUS_VERSION}
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
	AUDACIOUS_CONF="--enable-sse2 --disable-altivec"
	;;
    powerpc*|ppc*)
	AUDACIOUS_CONF="--enable-altivec --disable-sse2"
	AUDACIOUS_ENV="$AUDACIOUS_ENV CFLAGS='-O3 -pipe -Wall -maltivec'"
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
	    --enable-samplerate \
	    $AUDACIOUS_CONF \
	    || error
    ) || error "configure"
    
    make $MAKEARGS AR=${CROSS}ar || error

    install_sysroot_files || error

    install_fakeroot_init || error
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/audacious.installed"
}

build_audacious
