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

ATK_VERSION=1.28.0
ATK=atk-${ATK_VERSION}.tar.bz2
ATK_MIRROR=http://ftp.acc.umu.se/pub/gnome/sources/atk/1.28
ATK_DIR=$BUILD_DIR/atk-${ATK_VERSION}
ATK_ENV="$CROSS_ENV_AC"

build_atk() {
    test -e "$STATE_DIR/atk.installed" && return
    banner "Build atk"
    download $ATK_MIRROR $ATK
    extract $ATK
    apply_patches $ATK_DIR $ATK
    pushd $TOP_DIR
    cd $ATK_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ATK_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/atk.installed"
}

build_atk
