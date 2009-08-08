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

QT_X11_OPENSOURCE_SRC_VERSION=4.5.0
QT_X11_OPENSOURCE_SRC=qt-all-opensource-src-${QT_X11_OPENSOURCE_SRC_VERSION}.tar.bz2
QT_X11_OPENSOURCE_SRC_MIRROR=ftp://ftp.trolltech.com/qt/source
QT_X11_OPENSOURCE_SRC_DIR=$BUILD_DIR/qt-all-opensource-src-${QT_X11_OPENSOURCE_SRC_VERSION}
QT_X11_OPENSOURCE_SRC_ENV="$CROSS_ENV_AC 
QMAKE_CC=${CROSS}gcc 
QMAKE_CXX=${CROSS}g++ 
QMAKE_LINK=${CROSS}g++ 
QMAKE_LINK_SHLIB=${CROSS}g++ 
QMAKE_AR='${CROSS}ar cqs'
QMAKE_OBJCOPY='${CROSS}objcopy'
QMAKE_RANLIB='${CROSS}ranlib'
"

get_qt_arch() {
    case $1 in
    i386*|i486*|i586*|i686*)
	echo i386
	;;
    x86_64*|amd64*)
	echo x86_64
	;;
    arm*|xscale*)
	echo arm
	;;
    powerpc*|ppc*)
	echo powerpc
	;;
    powerpc64*|ppc64*)
	echo powerpc64
	;;
    mips*)
	echo mips
	;;
    *)
	echo $1
	;;
    esac
}

build_qt_x11_opensource_src() {
    test -e "$STATE_DIR/qt_x11_opensource_src.installed" && return
    banner "Build qt-x11-opensource-src"
    download $QT_X11_OPENSOURCE_SRC_MIRROR $QT_X11_OPENSOURCE_SRC
    extract $QT_X11_OPENSOURCE_SRC

    cp -R $QT_X11_OPENSOURCE_SRC_DIR/mkspecs/common $QT_X11_OPENSOURCE_SRC_DIR/mkspecs/common-cross
    cp -R $QT_X11_OPENSOURCE_SRC_DIR/mkspecs/linux-g++ $QT_X11_OPENSOURCE_SRC_DIR/mkspecs/linux-cross-${TARGET_ARCH/-*}
    
    apply_patches $QT_X11_OPENSOURCE_SRC_DIR $QT_X11_OPENSOURCE_SRC
    pushd $TOP_DIR

    sed -i -e "s:@CROSS@:${CROSS}:g" $QT_X11_OPENSOURCE_SRC_DIR/mkspecs/common-cross/g++.conf
    sed -i -e "s:@TARGET_DIR@:${TARGET_BIN_DIR}:g" $QT_X11_OPENSOURCE_SRC_DIR/mkspecs/common-cross/g++.conf

    sed -i -e "s:@CROSS@:${CROSS}:g" $QT_X11_OPENSOURCE_SRC_DIR/mkspecs/common-cross/linux.conf
    sed -i -e "s:@TARGET_DIR@:${TARGET_BIN_DIR}:g" $QT_X11_OPENSOURCE_SRC_DIR/mkspecs/common-cross/linux.conf

    sed -i -e "s:/common/:/common-cross/:g" $QT_X11_OPENSOURCE_SRC_DIR/mkspecs/linux-cross-${TARGET_ARCH/-*}/qmake.conf

    cd $QT_X11_OPENSOURCE_SRC_DIR
    (
    echo yes | eval \
	$CROSS_CONF_ENV \
	$QT_X11_OPENSOURCE_SRC_ENV \
	./configure -xplatform linux-cross-${TARGET_ARCH/-*} \
	    -arch `get_qt_arch ${TARGET_ARCH}` \
	    -prefix /usr \
	    -headerdir /usr/include/qt4 \
	    -plugindir /usr/lib/qt4/plugins \
	    -translationdir /usr/share/qt4/translations \
	    -sysconfdir /etc \
	    -sm \
	    -xshape \
	    -xinerama \
	    -xcursor \
	    -xfixes \
	    -xrandr \
	    -xrender \
	    -fontconfig \
	    -xkb \
	    -v \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make $MAKEARGS INSTALL_ROOT=$TARGET_BIN_DIR install || error

    local fla=""
    for f in $TARGET_LIB/*.prl ; do
	fla=`echo $f | sed 's/\.prl/\.la/'`
	echo $f $fla
	sed -i "s|-L/usr/lib|-L${TARGET_LIB}|g" $f
	sed -i "s|-L/usr/lib|-L${TARGET_LIB}|g" $fla
	sed -i -e "/^dependency_libs/s:\( \)\(/lib\|/usr/lib\):\1${TARGET_BIN_DIR}\2:g" \
	    -e "/^libdir=/s:\(libdir='\)\(/lib\|/usr/lib\):\1${TARGET_BIN_DIR}\2:g" $fla || true
    done

    sed -i "s|\$\$\[QT_INSTALL_HEADERS\]|$TARGET_INC/qt4|" $TARGET_BIN_DIR/mkspecs/common-cross/linux.conf
    sed -i "s|\$\$\[QT_INSTALL_LIBS\]|$TARGET_LIB|" $TARGET_BIN_DIR/mkspecs/common-cross/linux.conf

    export QMAKESPEC=$TARGET_BIN_DIR/mkspecs/default
    
    ln -sf $TARGET_BIN_DIR/bin/qmake $HOST_BIN_DIR/bin/qmake || error
    ln -sf $TARGET_BIN_DIR/bin/moc   $HOST_BIN_DIR/bin/moc   || error
    ln -sf $TARGET_BIN_DIR/bin/uic   $HOST_BIN_DIR/bin/uic   || error
    ln -sf $TARGET_BIN_DIR/bin/rcc   $HOST_BIN_DIR/bin/rcc   || error

    for f in libQt3Support  libQtNetwork  libQtSql   libQtWebKit \
    libQtCore      libQtOpenGL   libQtSvg   libQtXmlPatterns \
    libQtGui       libQtScript   libQtTest  libQtXml; do
	$INSTALL -D -m 644 lib/$f.so.4.5.0 $ROOTFS_DIR/usr/lib/$f.so.4.5.0 || error
	ln -sf $f.so.4.5.0 $ROOTFS_DIR/usr/lib/$f.so.4.5
	ln -sf $f.so.4.5.0 $ROOTFS_DIR/usr/lib/$f.so.4
	ln -sf $f.so.4.5.0 $ROOTFS_DIR/usr/lib/$f.so
	$STRIP $ROOTFS_DIR/usr/lib/$f.so.4.5.0 || error
    done
    
    cp -r $TARGET_LIB/qt4 $ROOTFS_DIR/usr/lib/ || error
    find $ROOTFS_DIR/usr/lib/qt4/ -name "*.so" | xargs $STRIP
    
    popd
    touch "$STATE_DIR/qt_x11_opensource_src.installed"
}

build_qt_x11_opensource_src
export QMAKESPEC=$TARGET_BIN_DIR/mkspecs/default
