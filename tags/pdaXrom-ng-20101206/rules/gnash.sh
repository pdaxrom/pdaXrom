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

GNASH_VERSION=0.8.5
GNASH=gnash-${GNASH_VERSION}.tar.bz2
GNASH_MIRROR=http://ftp.gnu.org/pub/gnu/gnash/0.8.5
GNASH_DIR=$BUILD_DIR/gnash-${GNASH_VERSION}
GNASH_ENV="$CROSS_ENV_AC"

build_gnash() {
    test -e "$STATE_DIR/gnash.installed" && return
    banner "Build gnash"
    download $GNASH_MIRROR $GNASH
    extract $GNASH
    apply_patches $GNASH_DIR $GNASH
    pushd $TOP_DIR
    cd $GNASH_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GNASH_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-gui=gtk \
	    --enable-media=ffmpeg \
	    --enable-atk \
	    --disable-glext \
	    --enable-cairo \
	    --enable-z \
	    --enable-jpeg \
	    --enable-png \
	    --enable-fontconfig \
	    --enable-Xft \
	    --enable-expat \
	    --enable-docbook=no \
	    --enable-renderer=cairo \
	    --with-atk-incl=$TARGET_INC \
	    --with-atk-lib=$TARGET_LIB \
	    --with-pango-incl=$TARGET_INC/pango-1.0 \
	    --with-pango-lib=$TARGET_LIB \
	    --with-cairo-incl=$TARGET_INC \
	    --with-cairo-lib=$TARGET_LIB \
	    --with-gtk2-incl=$TARGET_INC/gtk-2.0 \
	    --with-gtk2-lib=$TARGET_LIB \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    error "update install"

    popd
    touch "$STATE_DIR/gnash.installed"
}

build_gnash
