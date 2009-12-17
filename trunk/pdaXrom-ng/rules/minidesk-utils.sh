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

MINIDESK_UTILS_VERSION=svn
MINIDESK_UTILS=minidesk-utils-${MINIDESK_UTILS_VERSION}
MINIDESK_UTILS_SVN=http://pdaxrom.svn.sourceforge.net/svnroot/pdaxrom/trunk/minidesk-utils
MINIDESK_UTILS_DIR=$BUILD_DIR/minidesk-utils-${MINIDESK_UTILS_VERSION}
MINIDESK_UTILS_ENV="$CROSS_ENV_AC"

build_minidesk_utils() {
    test -e "$STATE_DIR/minidesk_utils.installed" && return
    banner "Build minidesk-utils"
    if [ ! -d $MINIDESK_UTILS_DIR ]; then
	download_svn $MINIDESK_UTILS_SVN $MINIDESK_UTILS
	cp -R $SRC_DIR/$MINIDESK_UTILS $MINIDESK_UTILS_DIR
	apply_patches $MINIDESK_UTILS_DIR $MINIDESK_UTILS
    fi
    pushd $TOP_DIR
    cd $MINIDESK_UTILS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MINIDESK_UTILS_ENV \
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
    touch "$STATE_DIR/minidesk_utils.installed"
}

build_minidesk_utils
