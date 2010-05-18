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

MIDORI_VERSION=0.2.1
MIDORI=midori-${MIDORI_VERSION}.tar.bz2
MIDORI_MIRROR=http://archive.xfce.org/src/apps/midori/0.2
MIDORI_DIR=$BUILD_DIR/midori-${MIDORI_VERSION}
MIDORI_ENV="$CROSS_ENV_AC"

build_midori() {
    test -e "$STATE_DIR/midori.installed" && return
    banner "Build midori"
    download $MIDORI_MIRROR $MIDORI
    extract $MIDORI
    apply_patches $MIDORI_DIR $MIDORI
    pushd $TOP_DIR
    cd $MIDORI_DIR
    (

    LINKFLAGS="-L${TARGET_LIB} -Wl,-rpath,${TARGET_LIB}" CC=${CROSS}gcc ./waf configure --prefix=/usr || error

    ) || error "configure"

    ./waf build || error

    ./waf install --destdir=${MIDORI_DIR}/fakeroot || error

    rm -rf fakeroot/usr/share/doc fakeroot/usr/share/locale || error

    find fakeroot/ -name "*.la" | xargs rm -f

    find fakeroot/ -type f -executable | xargs $STRIP

    install_fakeroot_finish || error

    if [ "$USE_WEBBROWSER" = "midori" ]; then
	mkdir -p $ROOTFS_DIR/etc/default/applications
	echo "WEBBROWSER=midori" > $ROOTFS_DIR/etc/default/applications/webbrowser
    fi

    popd
    touch "$STATE_DIR/midori.installed"
}

build_midori
