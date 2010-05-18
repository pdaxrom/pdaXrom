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

APR_VERSION=1.3.9
APR=apr-${APR_VERSION}.tar.bz2
APR_MIRROR=http://www.apache.org/dist/apr
APR_DIR=$BUILD_DIR/apr-${APR_VERSION}
APR_ENV="$CROSS_ENV_AC \
ac_cv_file__dev_zero=yes \
apr_cv_process_shared_works=yes \
apr_cv_mutex_robust_shared=yes \
apr_cv_tcp_nodelay_with_cork=yes \
ac_cv_sizeof_struct_iovec=1"

build_apr() {
    test -e "$STATE_DIR/apr.installed" && return
    banner "Build apr"
    download $APR_MIRROR $APR
    extract $APR
    apply_patches $APR_DIR $APR
    pushd $TOP_DIR
    cd $APR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$APR_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    ln -sf ${TARGET_BIN_DIR}/bin/apr-1-config ${HOST_BIN_DIR}/bin/apr-1-config || error "symlink"
    sed -i -e "s|prefix=\"/usr\"|prefix=$TARGET_BIN_DIR|" ${TARGET_BIN_DIR}/bin/apr-1-config

    install_fakeroot_init
    rm -rf fakeroot/usr/bin
    rm -rf fakeroot/usr/build-1
    rm -f fakeroot/usr/lib/apr.exp
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/apr.installed"
}

build_apr
