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

TARGET_GROFF_VERSION=1.20.1
TARGET_GROFF=groff-${TARGET_GROFF_VERSION}.tar.gz
TARGET_GROFF_MIRROR=ftp://ftp.gnu.org/gnu/groff
TARGET_GROFF_DIR=$BUILD_DIR/groff-${TARGET_GROFF_VERSION}
TARGET_GROFF_ENV="$CROSS_ENV_AC"

build_target_groff() {
    test -e "$STATE_DIR/target_groff.installed" && return
    banner "Build target-groff"
    download $TARGET_GROFF_MIRROR $TARGET_GROFF
    extract $TARGET_GROFF
    apply_patches $TARGET_GROFF_DIR $TARGET_GROFF
    pushd $TOP_DIR
    cd $TARGET_GROFF_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_GROFF_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init || error

    rm -rf fakeroot/usr/X11

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target_groff.installed"
}

build_target_groff
