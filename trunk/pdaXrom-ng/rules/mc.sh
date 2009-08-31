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

MC_VERSION=4.7.0-pre2
MC=mc-${MC_VERSION}.tar.gz
MC_MIRROR=http://www.midnight-commander.org/downloads/12
MC_DIR=$BUILD_DIR/mc-${MC_VERSION}
MC_ENV="$CROSS_ENV_AC"

build_mc() {
    test -e "$STATE_DIR/mc.installed" && return
    banner "Build mc"
    download $MC_MIRROR $MC
    extract $MC
    apply_patches $MC_DIR $MC
    pushd $TOP_DIR
    cd $MC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/mc \
	    --with-slang-includes=$TARGET_INC \
	    --with-slang-libs=$TARGET_LIB \
	    --enable-charset \
	    --with-edit \
	    || error
    ) || error "configure"
    make $MAKEARGS || error

    gcc src/man2hlp.c -o src/man2hlp -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -I. -lglib-2.0 || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/mc.installed"
}

build_mc
