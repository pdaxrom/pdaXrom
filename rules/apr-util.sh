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

APR_UTIL_VERSION=1.3.9
APR_UTIL=apr-util-${APR_UTIL_VERSION}.tar.bz2
APR_UTIL_MIRROR=http://www.apache.org/dist/apr
APR_UTIL_DIR=$BUILD_DIR/apr-util-${APR_UTIL_VERSION}
APR_UTIL_ENV="$CROSS_ENV_AC"

build_apr_util() {
    test -e "$STATE_DIR/apr_util.installed" && return
    banner "Build apr-util"
    download $APR_UTIL_MIRROR $APR_UTIL
    extract $APR_UTIL
    apply_patches $APR_UTIL_DIR $APR_UTIL
    pushd $TOP_DIR
    cd $APR_UTIL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$APR_UTIL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-apr=${TARGET_BIN_DIR} \
	    || error
    ) || error "configure"

    make $MAKEARGS apr_builddir=${APR_DIR}/build apr_builders=${APR_DIR}/build LIBTOOL=${APR_DIR}/libtool APR_MKDIR=${APR_DIR}/build/mkdir.sh || error

    install_sysroot_files apr_builddir=${APR_DIR}/build apr_builders=${APR_DIR}/build LIBTOOL=${APR_DIR}/libtool APR_MKDIR=${APR_DIR}/build/mkdir.sh || error

    ln -sf ${TARGET_BIN_DIR}/bin/apu-1-config ${HOST_BIN_DIR}/bin/apu-1-config || error "symlink"
    sed -i -e "s|prefix=\"/usr\"|prefix=$TARGET_BIN_DIR|" ${TARGET_BIN_DIR}/bin/apu-1-config

    install_fakeroot_init apr_builddir=${APR_DIR}/build apr_builders=${APR_DIR}/build LIBTOOL=${APR_DIR}/libtool APR_MKDIR=${APR_DIR}/build/mkdir.sh
    rm -rf fakeroot/usr/bin
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/apr_util.installed"
}

build_apr_util
