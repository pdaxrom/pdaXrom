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

LIBEXOSIP2_VERSION=3.3.0
LIBEXOSIP2=libeXosip2-${LIBEXOSIP2_VERSION}.tar.gz
LIBEXOSIP2_MIRROR=http://ftp.twaren.net/Unix/NonGNU/exosip
LIBEXOSIP2_DIR=$BUILD_DIR/libeXosip2-${LIBEXOSIP2_VERSION}
LIBEXOSIP2_ENV="$CROSS_ENV_AC"

build_libeXosip2() {
    test -e "$STATE_DIR/libeXosip2.installed" && return
    banner "Build libeXosip2"
    download $LIBEXOSIP2_MIRROR $LIBEXOSIP2
    extract $LIBEXOSIP2
    apply_patches $LIBEXOSIP2_DIR $LIBEXOSIP2
    pushd $TOP_DIR
    cd $LIBEXOSIP2_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBEXOSIP2_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    install_rootfs_usr_lib src/.libs/libeXosip2.so.4.2.0

    popd
    touch "$STATE_DIR/libeXosip2.installed"
}

build_libeXosip2
