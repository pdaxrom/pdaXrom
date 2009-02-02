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

ABIWORD=abiword-2.6.5.tar.gz
ABIWORD_MIRROR=http://www.abisource.com/downloads/abiword/2.6.5/source
ABIWORD_DIR=$BUILD_DIR/abiword-2.6.5
ABIWORD_ENV="$CROSS_ENV_AC"

build_abiword() {
    test -e "$STATE_DIR/abiword.installed" && return
    banner "Build abiword"
    download $ABIWORD_MIRROR $ABIWORD
    extract $ABIWORD
    apply_patches $ABIWORD_DIR $ABIWORD
    pushd $TOP_DIR
    cd $ABIWORD_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ABIWORD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-pspell \
	    --disable-spellcheck \
	    --disable-printing \
	    --disable-exports \
	    --disable-cocoa \
	    --with-x \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make $MAKEARGS DESTDIR=$ABIWORD_DIR/fakeroot install || error

    rm -rf fakeroot/usr/include fakeroot/usr/lib

    $STRIP fakeroot/usr/bin/abiword || error

    cp -R fakeroot/usr $ROOTFS_DIR/ || error

    popd
    touch "$STATE_DIR/abiword.installed"
}

build_abiword
