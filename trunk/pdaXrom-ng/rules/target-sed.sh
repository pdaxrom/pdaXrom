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

TARGET_SED_VERSION=4.2.1
TARGET_SED=sed-${TARGET_SED_VERSION}.tar.bz2
TARGET_SED_MIRROR=http://ftp.gnu.org/gnu/sed
TARGET_SED_DIR=$BUILD_DIR/sed-${TARGET_SED_VERSION}
TARGET_SED_ENV="$CROSS_ENV_AC"

build_target_sed() {
    test -e "$STATE_DIR/target_sed.installed" && return
    banner "Build target-sed"
    download $TARGET_SED_MIRROR $TARGET_SED
    extract $TARGET_SED
    apply_patches $TARGET_SED_DIR $TARGET_SED
    pushd $TOP_DIR
    cd $TARGET_SED_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_SED_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/sed \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init || error
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target_sed.installed"
}

build_target_sed
