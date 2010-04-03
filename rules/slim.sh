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

SLIM_VERSION=1.3.1
SLIM=slim-${SLIM_VERSION}.tar.gz
SLIM_MIRROR=http://download.berlios.de/slim
SLIM_DIR=$BUILD_DIR/slim-${SLIM_VERSION}
SLIM_ENV="$CROSS_ENV_AC"

build_slim() {
    test -e "$STATE_DIR/slim.installed" && return
    banner "Build slim"
    download $SLIM_MIRROR $SLIM
    extract $SLIM
    apply_patches $SLIM_DIR $SLIM
    pushd $TOP_DIR
    cd $SLIM_DIR

    make $MAKEARGS \
	CC=${CROSS}gcc \
	CXX=${CROSS}g++ \
	CFLAGS="-O2 -Wall -I${TARGET_INC} -I. `freetype-config --cflags`" \
	LDFLAGS="-Wl,-rpath,${TARGET_LIB} -L${TARGET_LIB} -lXft -lX11 -lfreetype -lXrender -lfontconfig -lpng12 -lz -lm -lcrypt -lXmu -lpng -ljpeg" \
	|| error

    #install_sysroot_files || error

    install_fakeroot_init
    $INSTALL -D -m 644 $GENERICFS_DIR/slim/slim.conf fakeroot/etc/slim.conf
    install_fakeroot_finish || error
    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/slim $ROOTFS_DIR/etc/init.d/slim || error "can't install slim init script"
    install_rc_start slim 99
    install_rc_stop  slim 01

    popd
    touch "$STATE_DIR/slim.installed"
}

build_slim
