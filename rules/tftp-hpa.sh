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

TFTP_HPA_VERSION=5.0
TFTP_HPA=tftp-hpa-${TFTP_HPA_VERSION}.tar.bz2
TFTP_HPA_MIRROR=http://www.kernel.org/pub/software/network/tftp
TFTP_HPA_DIR=$BUILD_DIR/tftp-hpa-${TFTP_HPA_VERSION}
TFTP_HPA_ENV="$CROSS_ENV_AC"

build_tftp_hpa() {
    test -e "$STATE_DIR/tftp_hpa.installed" && return
    banner "Build tftp-hpa"
    download $TFTP_HPA_MIRROR $TFTP_HPA
    extract $TFTP_HPA
    apply_patches $TFTP_HPA_DIR $TFTP_HPA
    pushd $TOP_DIR
    cd $TFTP_HPA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TFTP_HPA_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --without-tcpwrappers \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init INSTALLROOT=$PWD/fakeroot

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/tftp-hpa fakeroot/etc/init.d/tftp-hpa || error
    rm -rf fakeroot/man

    install_fakeroot_finish || error

    install_rc_start tftp-hpa 70
    install_rc_stop  tftp-hpa 30

    popd
    touch "$STATE_DIR/tftp_hpa.installed"
}

build_tftp_hpa
