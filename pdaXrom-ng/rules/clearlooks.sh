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

CLEARLOOKS_VERSION=0.6.2
CLEARLOOKS=clearlooks-${CLEARLOOKS_VERSION}.tar.bz2
CLEARLOOKS_MIRROR=http://downloads.sourceforge.net/clearlooks
CLEARLOOKS_DIR=$BUILD_DIR/clearlooks-${CLEARLOOKS_VERSION}
CLEARLOOKS_ENV="$CROSS_ENV_AC"

build_clearlooks() {
    test -e "$STATE_DIR/clearlooks.installed" && return
    banner "Build clearlooks"
    download $CLEARLOOKS_MIRROR $CLEARLOOKS
    extract $CLEARLOOKS
    apply_patches $CLEARLOOKS_DIR $CLEARLOOKS
    pushd $TOP_DIR
    cd $CLEARLOOKS_DIR

    autoreconf -i

    (
    eval \
	$CROSS_CONF_ENV \
	$CLEARLOOKS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-animation \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make -C themes DESTDIR=$ROOTFS_DIR install || error
    
    $INSTALL -D -m 644 src/.libs/libclearlooks.so $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/engines/libclearlooks.so || error
    $STRIP $ROOTFS_DIR/usr/lib/gtk-2.0/2.10.0/engines/libclearlooks.so

    echo "gtk-theme-name=\"Clearlooks\"" >> $ROOTFS_DIR/etc/gtk-2.0/gtkrc

    popd
    touch "$STATE_DIR/clearlooks.installed"
}

build_clearlooks
