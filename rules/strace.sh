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

STRACE_VERSION=4.5.20
STRACE=strace-${STRACE_VERSION}.tar.bz2
STRACE_MIRROR=http://downloads.sourceforge.net/project/strace/strace/4.5.20
STRACE_DIR=$BUILD_DIR/strace-${STRACE_VERSION}
STRACE_ENV="$CROSS_ENV_AC"

build_strace() {
    test -e "$STATE_DIR/strace.installed" && return
    banner "Build strace"
    download $STRACE_MIRROR $STRACE
    extract $STRACE
    apply_patches $STRACE_DIR $STRACE
    pushd $TOP_DIR
    cd $STRACE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$STRACE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    rm -f fakeroot/usr/bin/strace-graph
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/strace.installed"
}

build_strace
