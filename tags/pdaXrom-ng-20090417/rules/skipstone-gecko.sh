#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

SKIPSTONE_GECKO=skipstone-1.0.1.tar.gz
SKIPSTONE_GECKO_MIRROR=http://www.muhri.net/skipstone
SKIPSTONE_GECKO_DIR=$BUILD_DIR/skipstone-1.0.1
SKIPSTONE_GECKO_ENV="$CROSS_ENV_AC"

build_skipstone_gecko() {
    test -e "$STATE_DIR/skipstone_gecko.installed" && return
    banner "Build skipstone-gecko"
    download $SKIPSTONE_GECKO_MIRROR $SKIPSTONE_GECKO
    extract $SKIPSTONE_GECKO
    apply_patches $SKIPSTONE_GECKO_DIR $SKIPSTONE_GECKO
    pushd $TOP_DIR
    cd $SKIPSTONE_GECKO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SKIPSTONE_GECKO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-mozilla-includes=$FIREFOX_DIR/dist/include \
	    --with-mozilla-libs=$FIREFOX_DIR/dist/firefox \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    error "update install"

    popd
    touch "$STATE_DIR/skipstone_gecko.installed"
}

build_skipstone_gecko
