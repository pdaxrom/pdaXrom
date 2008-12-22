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

GAMIN=gamin-0.1.10.tar.bz2
GAMIN_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/gamin/0.1
GAMIN_DIR=$BUILD_DIR/gamin-0.1.10
GAMIN_ENV="$CROSS_ENV_AC"

build_gamin() {
    test -e "$STATE_DIR/gamin.installed" && return
    banner "Build gamin"
    download $GAMIN_MIRROR $GAMIN
    extract $GAMIN
    apply_patches $GAMIN_DIR $GAMIN
    pushd $TOP_DIR
    cd $GAMIN_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GAMIN_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --without-python \
	    --disable-gtk-doc \
	    --disable-docs \
	    --libexecdir=/usr/lib/gamin
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 libgamin/.libs/libfam.so.0.0.0 $ROOTFS_DIR/usr/lib/libfam.so.0.0.0 || error
    ln -sf libfam.so.0.0.0 $ROOTFS_DIR/usr/lib/libfam.so.0
    ln -sf libfam.so.0.0.0 $ROOTFS_DIR/usr/lib/libfam.so
    $STRIP $ROOTFS_DIR/usr/lib/libfam.so.0.0.0
    
    $INSTALL -D -m 644 libgamin/.libs/libgamin-1.so.0.1.10 $ROOTFS_DIR/usr/lib/libgamin-1.so.0.1.10 || error
    ln -sf libgamin-1.so.0.1.10 $ROOTFS_DIR/usr/lib/libgamin-1.so.0
    ln -sf libgamin-1.so.0.1.10 $ROOTFS_DIR/usr/lib/libgamin-1.so
    $STRIP $ROOTFS_DIR/usr/lib/libgamin-1.so.0.1.10
    
    $INSTALL -D -m 755 server/gam_server $ROOTFS_DIR/usr/lib/gamin/gam_server || error
    $STRIP $ROOTFS_DIR/usr/lib/gamin/gam_server

    popd
    touch "$STATE_DIR/gamin.installed"
}

build_gamin
