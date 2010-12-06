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

IPTABLES_VERSION=1.4.6
IPTABLES=iptables-${IPTABLES_VERSION}.tar.bz2
IPTABLES_MIRROR=http://www.netfilter.org/projects/iptables/files
IPTABLES_DIR=$BUILD_DIR/iptables-${IPTABLES_VERSION}
IPTABLES_ENV="$CROSS_ENV_AC CFLAGS='-DNO_SHARED_LIBS=1'"

build_iptables() {
    test -e "$STATE_DIR/iptables.installed" && return
    banner "Build iptables"
    download $IPTABLES_MIRROR $IPTABLES
    extract $IPTABLES
    apply_patches $IPTABLES_DIR $IPTABLES
    pushd $TOP_DIR
    cd $IPTABLES_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$IPTABLES_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/iptables \
	    --enable-static \
	    --disable-shared \
	    --disable-ipv6 \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/iptables.installed"
}

build_iptables
