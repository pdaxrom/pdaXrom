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

ATTR_VERSION=2.4.44
ATTR=attr-${ATTR_VERSION}.src.tar.gz
ATTR_MIRROR=http://download.savannah.gnu.org/releases/attr
ATTR_DIR=$BUILD_DIR/attr-${ATTR_VERSION}
ATTR_ENV="$CROSS_ENV_AC"

build_attr() {
    test -e "$STATE_DIR/attr.installed" && return
    banner "Build attr"
    download $ATTR_MIRROR $ATTR
    extract $ATTR
    apply_patches $ATTR_DIR $ATTR
    pushd $TOP_DIR
    cd $ATTR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ATTR_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files prefix=${TARGET_BIN_DIR}/usr install-dev install-lib || error

    install_fakeroot_init prefix=${ATTR_DIR}/fakeroot/usr install-lib

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/attr.installed"
}

build_attr
