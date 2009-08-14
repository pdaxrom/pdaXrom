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

AUDACIOUS_PLUGINS=audacious-plugins-1.5.1.tbz2
AUDACIOUS_PLUGINS_MIRROR=http://distfiles.atheme.org
AUDACIOUS_PLUGINS_DIR=$BUILD_DIR/audacious-plugins-1.5.1
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
    eval \
	$CROSS_CONF_ENV \
	$AUDACIOUS_PLUGINS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --disable-dbus \
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
	    --disable-vorbis \
	    --disable-flacng \
	    --disable-musepack \
	    --disable-wma \
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
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make DESTDIR=$AUDACIOUS_PLUGINS_DIR install || error
    
    cd ./$TARGET_BIN_DIR || error
    
    find . -name "*.so" | while read f; do
	echo "install $f"
	$INSTALL -D -m 644 $f $ROOTFS_DIR/$f || error
	$STRIP $ROOTFS_DIR/$f
    done

    popd
    touch "$STATE_DIR/audacious_plugins.installed"
}

build_audacious_plugins
