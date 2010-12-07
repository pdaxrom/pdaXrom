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

LVM2_VERSION=2.02.78
LVM2=LVM2.${LVM2_VERSION}.tgz
LVM2_MIRROR=ftp://sources.redhat.com/pub/lvm2
LVM2_DIR=$BUILD_DIR/LVM2.${LVM2_VERSION}
LVM2_ENV="$CROSS_ENV_AC LIBS=-L$TARGET_LIB \
ac_cv_func_realloc_0_nonnull=yes \
"

build_LVM2() {
    test -e "$STATE_DIR/LVM2.installed" && return
    banner "Build LVM2"
    download $LVM2_MIRROR $LVM2
    extract $LVM2
    apply_patches $LVM2_DIR $LVM2
    pushd $TOP_DIR
    cd $LVM2_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LVM2_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-pkgconfig \
	    || error
    ) || error "configure"

    make $MAKEARGS CC=${CROSS}gcc RANLIB=${CROSS}ranlib || error

    install_sysroot_files || error "install sysroot files"

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/LVM2.installed"
}

build_LVM2
