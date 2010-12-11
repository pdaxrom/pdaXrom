#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

THUNAR_VERSION=1.1.5
THUNAR=Thunar-${THUNAR_VERSION}.tar.bz2
THUNAR_MIRROR=http://mocha.xfce.org/archive/xfce/4.8pre2/src
THUNAR_DIR=$BUILD_DIR/Thunar-${THUNAR_VERSION}
THUNAR_ENV="$CROSS_ENV_AC"

build_Thunar() {
    test -e "$STATE_DIR/Thunar.installed" && return
    banner "Build Thunar"
    download $THUNAR_MIRROR $THUNAR
    extract $THUNAR
    apply_patches $THUNAR_DIR $THUNAR
    pushd $TOP_DIR
    cd $THUNAR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$THUNAR_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/Thunar.installed"
}

build_Thunar
