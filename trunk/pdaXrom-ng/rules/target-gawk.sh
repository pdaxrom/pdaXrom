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

TARGET_GAWK_VERSION=3.1.7
TARGET_GAWK=gawk-${TARGET_GAWK_VERSION}.tar.bz2
TARGET_GAWK_MIRROR=http://ftp.gnu.org/gnu/gawk
TARGET_GAWK_DIR=$BUILD_DIR/gawk-${TARGET_GAWK_VERSION}
TARGET_GAWK_ENV="$CROSS_ENV_AC"

build_target_gawk() {
    test -e "$STATE_DIR/target_gawk.installed" && return
    banner "Build target_gawk"
    download $TARGET_GAWK_MIRROR $TARGET_GAWK
    extract $TARGET_GAWK
    apply_patches $TARGET_GAWK_DIR $TARGET_GAWK
    pushd $TOP_DIR
    cd $TARGET_GAWK_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_GAWK_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-libsigsegv \
	    --disable-lint \
	    --enable-switch \
	    --libexecdir=/usr/lib/gawk \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_fakeroot_init || error

    ln -sf gawk-${TARGET_GAWK_VERSION} fakeroot/usr/bin/gawk
    ln -sf pgawk-${TARGET_GAWK_VERSION} fakeroot/usr/bin/pgawk

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target_gawk.installed"
}

build_target_gawk
