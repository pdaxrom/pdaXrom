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

SG3_UTILS_VERSION=1.30
SG3_UTILS=sg3_utils-${SG3_UTILS_VERSION}.tgz
SG3_UTILS_MIRROR=http://sg.danny.cz/sg/p
SG3_UTILS_DIR=$BUILD_DIR/sg3_utils-${SG3_UTILS_VERSION}
SG3_UTILS_ENV="$CROSS_ENV_AC"

build_sg3_utils() {
    test -e "$STATE_DIR/sg3_utils.installed" && return
    banner "Build sg3_utils"
    download $SG3_UTILS_MIRROR $SG3_UTILS
    extract $SG3_UTILS
    apply_patches $SG3_UTILS_DIR $SG3_UTILS
    pushd $TOP_DIR
    cd $SG3_UTILS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SG3_UTILS_ENV \
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
    touch "$STATE_DIR/sg3_utils.installed"
}

build_sg3_utils
