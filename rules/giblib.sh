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

#
# i use static because only scrot use it
#

GIBLIB=giblib-1.2.4.tar.gz
GIBLIB_MIRROR=http://linuxbrit.co.uk/downloads
GIBLIB_DIR=$BUILD_DIR/giblib-1.2.4
GIBLIB_ENV="$CROSS_ENV_AC"

build_giblib() {
    test -e "$STATE_DIR/giblib.installed" && return
    banner "Build giblib"
    download $GIBLIB_MIRROR $GIBLIB
    extract $GIBLIB
    apply_patches $GIBLIB_DIR $GIBLIB
    pushd $TOP_DIR
    cd $GIBLIB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GIBLIB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-static \
	    --disable-shared \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    ln -sf $TARGET_BIN_DIR/bin/giblib-config $HOST_BIN_DIR/bin/ || error

    popd
    touch "$STATE_DIR/giblib.installed"
}

build_giblib
