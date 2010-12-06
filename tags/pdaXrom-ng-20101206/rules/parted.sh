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

PARTED_VERSION=1.8.8
PARTED=parted-${PARTED_VERSION}.tar.gz
PARTED_MIRROR=http://ftp.gnu.org/gnu/parted
PARTED_DIR=$BUILD_DIR/parted-${PARTED_VERSION}
PARTED_ENV="$CROSS_ENV_AC \
ac_cv_func_malloc_0_nonnull=yes \
ac_cv_func_calloc_0_nonnull=yes \
ac_cv_func_realloc_0_nonnull=yes \
ac_cv_func_memcmp_working=yes \
"

build_parted() {
    test -e "$STATE_DIR/parted.installed" && return
    banner "Build parted"
    download $PARTED_MIRROR $PARTED
    extract $PARTED
    apply_patches $PARTED_DIR $PARTED
    pushd $TOP_DIR
    cd $PARTED_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PARTED_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-Werror \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/parted.installed"
}

build_parted
