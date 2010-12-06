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

HTOP_VERSION=0.8.3
HTOP=htop-${HTOP_VERSION}.tar.gz
HTOP_MIRROR=http://downloads.sourceforge.net/project/htop/htop/0.8.3
HTOP_DIR=$BUILD_DIR/htop-${HTOP_VERSION}
HTOP_ENV="$CROSS_ENV_AC
ac_cv_file__proc_stat=yes
ac_cv_file__proc_meminfo=yes
ac_cv_func_realloc_0_nonnull=yes
"

build_htop() {
    test -e "$STATE_DIR/htop.installed" && return
    banner "Build htop"
    download $HTOP_MIRROR $HTOP
    extract $HTOP
    apply_patches $HTOP_DIR $HTOP
    pushd $TOP_DIR
    cd $HTOP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$HTOP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/htop.installed"
}

build_htop
