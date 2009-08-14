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

STUNNEL_VERSION=4.26
STUNNEL=stunnel-${STUNNEL_VERSION}.tar.gz
STUNNEL_MIRROR=http://www.stunnel.org/download/stunnel/src
STUNNEL_DIR=$BUILD_DIR/stunnel-${STUNNEL_VERSION}
STUNNEL_ENV="$CROSS_ENV_AC
ac_cv_file___dev_ptmx_=yes 
ac_cv_file___dev_ptc_=no
ac_cv_file___dev_urandom_=yes
"

build_stunnel() {
    test -e "$STATE_DIR/stunnel.installed" && return
    banner "Build stunnel"
    download $STUNNEL_MIRROR $STUNNEL
    extract $STUNNEL
    apply_patches $STUNNEL_DIR $STUNNEL
    pushd $TOP_DIR
    cd $STUNNEL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$STUNNEL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --localstatedir=/var \
	    --with-ssl=$TARGET_BIN_DIR \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 src/stunnel $ROOTFS_DIR/usr/bin/stunnel || error
    $STRIP $ROOTFS_DIR/usr/bin/stunnel || error

    popd
    touch "$STATE_DIR/stunnel.installed"
}

build_stunnel
