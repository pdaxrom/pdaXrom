SIMPLENX_SVN_DIR=${TOP_DIR}/../simple-nx/trunk

simplenx_gui() {
    test -e "$STATE_DIR/simplenx_gui.installed" && return
    pushd $TOP_DIR
    cd $SIMPLENX_SVN_DIR/client/SimpleNX-fltk
    make clean
    
    make -f Makefile.shared CC=${CROSS}gcc CXX=${CROSS}g++ $MAKEARGS || error

    $INSTALL -D -m 755 simplenx-gui $ROOTFS_DIR/usr/bin/simplenx-gui || error
    $STRIP $ROOTFS_DIR/usr/bin/simplenx-gui

    $INSTALL -D -m 644 logo.png $ROOTFS_DIR/usr/etc/logo.png || error
    $INSTALL -D -m 644 simplenx.desktop $ROOTFS_DIR/usr/share/applications/simplenx.desktop || error
    $INSTALL -D -m 644 $SIMPLENX_SVN_DIR/../etc/cert.pem $ROOTFS_DIR/usr/etc/cert.pem || error

    make clean
    
    popd
    touch "$STATE_DIR/simplenx_gui.installed"
}

simplenx_gui

simplenx_nxcomp() {
    test -e "$STATE_DIR/simplenx_nxcomp.installed" && return

    pushd $TOP_DIR
    cd $SIMPLENX_SVN_DIR/nxcore3-rame/nxcomp
    test -f Makefile && make distclean

    ./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	--prefix=/usr \
	--sysconfdir=/etc

    make $MAKEARGS LDFLAGS="-L$TARGET_LIB" || error

    $INSTALL -D -m 644 libXcomp.so.3.2-mipc $TARGET_LIB/libXcomp.so.3.2 || error
    ln -sf libXcomp.so.3.2 $TARGET_LIB/libXcomp.so.3
    ln -sf libXcomp.so.3.2 $TARGET_LIB/libXcomp.so

    $INSTALL -D -m 644 libXcomp.so.3.2-mipc $ROOTFS_DIR/usr/lib/libXcomp.so.3.2 || error
    ln -sf libXcomp.so.3.2 $ROOTFS_DIR/usr/lib/libXcomp.so.3
    ln -sf libXcomp.so.3.2 $ROOTFS_DIR/usr/lib/libXcomp.so
    $STRIP $ROOTFS_DIR/usr/lib/libXcomp.so.3.2 || error

    make distclean
    popd    
    touch "$STATE_DIR/simplenx_nxcomp.installed"
}

simplenx_nxcomp

simplenx_nxproxy() {
    test -e "$STATE_DIR/simplenx_nxproxy.installed" && return

    pushd $TOP_DIR
    cd $SIMPLENX_SVN_DIR/nxcore3-rame/nxproxy
    test -f Makefile && make distclean

    ./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	--prefix=/usr \
	--sysconfdir=/etc

    make $MAKEARGS LDFLAGS="-L$TARGET_LIB -L,-rpath,$TARGET_LIB -lpng -ljpeg -lz" || error

    $INSTALL -D -m 755 nxproxy $ROOTFS_DIR/usr/bin/nxproxy || error
    $STRIP $ROOTFS_DIR/usr/bin/nxproxy

    make distclean

    touch "$STATE_DIR/simplenx_nxproxy.installed"
}

simplenx_nxproxy

simplenx_tune()
{
    rm -rf $ROOTFS_DIR/usr/share/pekwm/
    cp -R $GENERICFS_DIR/simplenx/pekwm $ROOTFS_DIR/usr/share || error
    cp -f $GENERICFS_DIR/simplenx/xinitrc $ROOTFS_DIR/etc/X11/xinit/xinitrc || error
    test -d $ROOTFS_DIR/usr/lib/dri && rm -f $ROOTFS_DIR/usr/lib/dri/*
}

simplenx_tune
