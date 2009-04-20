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

MIDORI_VERSION=0.1.6
MIDORI=midori-${MIDORI_VERSION}.tar.bz2
MIDORI_MIRROR=http://goodies.xfce.org/releases/midori
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

    cp -R fakeroot/etc $ROOTFS_DIR/ || error "copy target binaries"
    cp -R fakeroot/usr $ROOTFS_DIR/ || error "copy target binaries"

    popd
    touch "$STATE_DIR/midori.installed"
}

build_midori
