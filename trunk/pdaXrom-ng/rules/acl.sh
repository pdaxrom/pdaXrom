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

ACL_VERSION=2.2.49
ACL=acl-${ACL_VERSION}.src.tar.gz
ACL_MIRROR=http://download.savannah.gnu.org/releases/acl
ACL_DIR=$BUILD_DIR/acl-${ACL_VERSION}
ACL_ENV="$CROSS_ENV_AC"

build_acl() {
    test -e "$STATE_DIR/acl.installed" && return
    banner "Build acl"
    download $ACL_MIRROR $ACL
    extract $ACL
    apply_patches $ACL_DIR $ACL
    pushd $TOP_DIR
    cd $ACL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ACL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files prefix=${TARGET_BIN_DIR}/usr install-dev install-lib || error

    install_fakeroot_init prefix=${ACL_DIR}/fakeroot/usr install-lib

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/acl.installed"
}

build_acl
