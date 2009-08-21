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

AUDACIOUS_PLUGINS_VERSION=1.5.1
AUDACIOUS_PLUGINS=audacious-plugins-${AUDACIOUS_PLUGINS_VERSION}.tgz
AUDACIOUS_PLUGINS_MIRROR=http://distfiles.atheme.org
AUDACIOUS_PLUGINS_DIR=$BUILD_DIR/audacious-plugins-${AUDACIOUS_PLUGINS_VERSION}
AUDACIOUS_PLUGINS_ENV="$CROSS_ENV_AC"

build_audacious_plugins() {
    test -e "$STATE_DIR/audacious_plugins.installed" && return
    banner "Build audacious-plugins"
    download $AUDACIOUS_PLUGINS_MIRROR $AUDACIOUS_PLUGINS
    extract $AUDACIOUS_PLUGINS
    apply_patches $AUDACIOUS_PLUGINS_DIR $AUDACIOUS_PLUGINS
    pushd $TOP_DIR
    cd $AUDACIOUS_PLUGINS_DIR
    (
    local AUDACIOUS_CONF=
    case $TARGET_ARCH in
    i686*)
	AUDACIOUS_CONF="--enable-sse2 --disable-altivec"
	;;
    powerpc*|ppc*)
	AUDACIOUS_CONF="--enable-altivec --disable-sse2"
	AUDACIOUS_PLUGINS_ENV="$AUDACIOUS_ENV CFLAGS='-O3 -pipe -Wall -maltivec'"
	;;
    *)
	AUDACIOUS_CONF="--disable-sse2 --disable-altivec"
	;;
    esac

    eval \
	$CROSS_CONF_ENV \
	$AUDACIOUS_PLUGINS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --disable-dbus \
	    --disable-bluetooth \
	    --disable-esd \
	    --disable-pulse \
	    --disable-coreaudio \
	    --disable-dockalbumart \
	    --disable-jack \
	    --disable-arts \
	    --disable-oss \
	    --disable-libmadtest \
	    --disable-gnomeshortcuts \
	    --disable-rootvis \
	    --disable-musepack \
	    --disable-ape \
	    --disable-wavpack \
	    --disable-aac \
	    --disable-sid \
	    --disable-tta \
	    --disable-projectm \
	    --disable-amidiplug \
	    --disable-amidiplug-alsa \
	    --disable-amidiplug-flsyn \
	    --disable-amidiplug-dummy \
	    --disable-paranormal \
	    --with-libmad=$TARGET_BIN_DIR \
	    --disable-libmadtest \
	    --disable-mtp_up \
	    $AUDACIOUS_CONF \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_fakeroot_init pluginlibdir=/usr/lib/audacious || error
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/audacious_plugins.installed"
}

build_audacious_plugins
