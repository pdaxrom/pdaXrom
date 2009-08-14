PCIO_SVN_DIR=${TOP_DIR}/../RAME/trunk

pcio_libpcioclient() {
    test -e "$STATE_DIR/pcio_libpcioclient.installed" && return

    pushd $TOP_DIR
    cd $PCIO_SVN_DIR/client/libpcioclient
    test -f Makefile && make distclean

    ./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	--disable-shared \
	--with-pic || error "configure"

    make $MAKEARGS LDFLAGS="-L$TARGET_LIB" || error

    popd
    touch "$STATE_DIR/pcio_libpcioclient.installed"
}

pcio_libpcioclient

pcio_login() {
    test -e "$STATE_DIR/pcio_login.installed" && return
    pushd $TOP_DIR
    cd $PCIO_SVN_DIR/client/login
    
    test -f Makefile && make distclean

    qmake || error "qmake"
    
    make $MAKEARGS || error "make"


    $INSTALL -D -m 755 login $ROOTFS_DIR/home/.pcio/bin/login || error
    cp -R *.qm $ROOTFS_DIR/home/.pcio/bin/ || error
    $STRIP $ROOTFS_DIR/home/.pcio/bin/login || error

    make clean

    popd
    touch "$STATE_DIR/pcio_login.installed"
}

pcio_login

pcio_nxcomp() {
    test -e "$STATE_DIR/pcio_nxcomp.installed" && return

    pushd $TOP_DIR
    cd $PCIO_SVN_DIR/nxcore3/nxcomp
    test -f Makefile && make distclean

    ./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	--prefix=/usr \
	--sysconfdir=/etc

    make $MAKEARGS LDFLAGS="-L$TARGET_LIB" || error

    $INSTALL -D -m 644 libXcomp.so.3.3.0-mipc $TARGET_LIB/libXcomp.so.3.3.0 || error
    ln -sf libXcomp.so.3.3.0 $TARGET_LIB/libXcomp.so.3
    ln -sf libXcomp.so.3.3.0 $TARGET_LIB/libXcomp.so

    $INSTALL -D -m 644 libXcomp.so.3.3.0-mipc $ROOTFS_DIR/home/.pcio/lib/libXcomp.so.3.3.0 || error
    ln -sf libXcomp.so.3.3.0 $ROOTFS_DIR/home/.pcio/lib/libXcomp.so.3
    ln -sf libXcomp.so.3.3.0 $ROOTFS_DIR/home/.pcio/lib/libXcomp.so
    $STRIP $ROOTFS_DIR/home/.pcio/lib/libXcomp.so.3.3.0 || error

    make distclean
    popd

    touch "$STATE_DIR/pcio_nxcomp.installed"
}

pcio_nxcomp

pcio_nxproxy() {
    test -e "$STATE_DIR/pcio_nxproxy.installed" && return

    pushd $TOP_DIR
    cd $PCIO_SVN_DIR/nxcore3/nxproxy
    test -f Makefile && make distclean

    ./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	--prefix=/usr \
	--sysconfdir=/etc

    make $MAKEARGS LDFLAGS="-L$TARGET_LIB -L,-rpath,$TARGET_LIB -lpng -ljpeg -lz" || error

    $INSTALL -D -m 755 nxproxy $ROOTFS_DIR/home/.pcio/bin/rmproxy || error
    $STRIP $ROOTFS_DIR/home/.pcio/bin/rmproxy

    make distclean
    popd

    touch "$STATE_DIR/pcio_nxproxy.installed"
}

pcio_nxproxy

pcio_rmdialog() {
    test -e "$STATE_DIR/pcio_rmdialog.installed" && return

    pushd $TOP_DIR
    cd $PCIO_SVN_DIR/client/rmdialog
    test -f Makefile && make clean

    make CC=${CROSS}gcc CXX=${CROSS}g++ $MAKEARGS || error

    $INSTALL -D -m 755 rmdialog $ROOTFS_DIR/home/.pcio/bin/rmdialog || error
    $STRIP $ROOTFS_DIR/home/.pcio/bin/rmdialog

    popd
    touch "$STATE_DIR/pcio_rmdialog.installed"
}

pcio_rmdialog

pcio_rmsystem() {
    test -e "$STATE_DIR/pcio_rmsystem.installed" && return

    pushd $TOP_DIR
    cd $PCIO_SVN_DIR/client/rmsystem
    test -f Makefile && make distclean

    ./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	--prefix=/usr \
	--sysconfdir=/etc

    make $MAKEARGS || error
    #LDFLAGS="-L$TARGET_LIB -L,-rpath,$TARGET_LIB -lpng -ljpeg -lz" || error

    $INSTALL -D -m 755 src/rmsystem $ROOTFS_DIR/home/.pcio/bin/rmsystem || error
    $STRIP $ROOTFS_DIR/home/.pcio/bin/rmsystem

    make distclean
    popd

    touch "$STATE_DIR/pcio_rmsystem.installed"
}

pcio_rmsystem

pcio_rmftpd() {
    test -e "$STATE_DIR/pcio_rmftpd.installed" && return

    pushd $TOP_DIR
    cd $PCIO_SVN_DIR/client/rmftpd
    test -f Makefile && make distclean

    sh ./configure.rame --build=$BUILD_ARCH --host=$TARGET_ARCH \
	--prefix=/usr \
	--sysconfdir=/etc

    make $MAKEARGS || error
    #LDFLAGS="-L$TARGET_LIB -L,-rpath,$TARGET_LIB -lpng -ljpeg -lz" || error

    $INSTALL -D -m 755 src/rmftpd $ROOTFS_DIR/home/.pcio/bin/rmftpd || error
    $STRIP $ROOTFS_DIR/home/.pcio/bin/rmftpd

    make distclean
    popd

    touch "$STATE_DIR/pcio_rmftpd.installed"
}

pcio_rmftpd

pcio_rmprintd() {
    test -e "$STATE_DIR/pcio_rmprintd.installed" && return
    pushd $TOP_DIR
    cd $PCIO_SVN_DIR/rmprintd/rmprintd2

    test -f Makefile && make distclean

    qmake || error "qmake"

    make $MAKEARGS || error "make"

    $INSTALL -D -m 755 rmprintd $ROOTFS_DIR/home/.pcio/bin/rmprintd || error
    $STRIP $ROOTFS_DIR/home/.pcio/bin/rmprintd || error

    make clean
    popd

    touch "$STATE_DIR/pcio_rmprintd.installed"
}

pcio_rmprintd

pcio_tune()
{
    ln -sf /usr/bin/stunnel $ROOTFS_DIR/home/.pcio/bin/stunnel || error
    rm -rf $ROOTFS_DIR/usr/share/pekwm/
    cp -R $GENERICFS_DIR/simplenx/pekwm $ROOTFS_DIR/usr/share || error
    cp -f $GENERICFS_DIR/pcio/xinitrc $ROOTFS_DIR/etc/X11/xinit/xinitrc || error
    cp -f $GENERICFS_DIR/pcio/hosts $ROOTFS_DIR/home/.pcio/bin/hosts || error
    test -d $ROOTFS_DIR/usr/lib/dri && rm -f $ROOTFS_DIR/usr/lib/dri/*
}

pcio_tune
