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

FILE_VERSION=5.03
FILE=file-${FILE_VERSION}.tar.gz
FILE_MIRROR=ftp://ftp.astron.com/pub/file
FILE_DIR=$BUILD_DIR/file-${FILE_VERSION}
FILE_ENV="$CROSS_ENV_AC"

build_file() {
    test -e "$STATE_DIR/file.installed" && return
    banner "Build file"
    download $FILE_MIRROR $FILE
    extract $FILE
    apply_patches $FILE_DIR $FILE
    pushd $TOP_DIR
    cd $FILE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$FILE_ENV \
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
    touch "$STATE_DIR/file.installed"
}

build_file
