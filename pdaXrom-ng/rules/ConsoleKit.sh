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

CONSOLEKIT_VERSION=0.4.3
CONSOLEKIT=ConsoleKit-${CONSOLEKIT_VERSION}.tar.bz2
CONSOLEKIT_MIRROR=http://www.freedesktop.org/software/ConsoleKit/dist
CONSOLEKIT_DIR=$BUILD_DIR/ConsoleKit-${CONSOLEKIT_VERSION}
CONSOLEKIT_ENV="$CROSS_ENV_AC"

build_ConsoleKit() {
    test -e "$STATE_DIR/ConsoleKit.installed" && return
    banner "Build ConsoleKit"
    download $CONSOLEKIT_MIRROR $CONSOLEKIT
    extract $CONSOLEKIT
    apply_patches $CONSOLEKIT_DIR $CONSOLEKIT
    pushd $TOP_DIR
    cd $CONSOLEKIT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$CONSOLEKIT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/ConsoleKit \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    sed -i -e 's|/usr/include|${prefix}/include|' ${TARGET_LIB}/pkgconfig/ck-connector.pc

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/ConsoleKit.installed"
}

build_ConsoleKit
