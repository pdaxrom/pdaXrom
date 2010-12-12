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

EXO_VERSION=0.5.5
EXO=exo-${EXO_VERSION}.tar.bz2
EXO_MIRROR=http://archive.xfce.org/src/xfce/exo/0.5
EXO_DIR=$BUILD_DIR/exo-${EXO_VERSION}
EXO_ENV="$CROSS_ENV_AC
ac_cv_func_mmap_fixed_mapped=yes \
ac_cv_func_munmap=yes \
ac_cv_func_malloc_0_nonnull=yes \
ac_cv_func_strnlen_working=yes \
gt_cv_func_printf_posix=yes \
gt_cv_int_divbyzero_sigfpe=yes \
"

build_exo() {
    test -e "$STATE_DIR/exo.installed" && return
    banner "Build exo"
    download $EXO_MIRROR $EXO
    extract $EXO
    apply_patches $EXO_DIR $EXO
    pushd $TOP_DIR
    cd $EXO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$EXO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-python \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error
    # compatibility for Terminal
    ln -sf exo-1.pc ${TARGET_LIB}/pkgconfig/exo-0.3.pc

    install_fakeroot_init
    rm -f fakeroot/usr/bin/exo-csource
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/exo.installed"
}

build_exo
