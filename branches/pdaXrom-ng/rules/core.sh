#!/bin/bash

#
# Cygwin cross compiler build script v1.0
# Template pdaXrom builder v2 http://wiki.pdaXrom.org
#

error() {
    echo "ERROR: $1"
    exit 1
}

#TOOLCHAIN_PREFIX="/opt/cell/toolchain"
#TARGET_ARCH="powerpc-linux"
#CROSS=ppu-
#GLIBC_DIR="$TOOLCHAIN_PREFIX/../sysroot/lib"

#MAKEARGS=-j4

HOST_SYSTEM=`uname`
BUILD_ARCH=
case $HOST_SYSTEM in
Linux)
    BUILD_ARCH=`uname -m`-unknown-linux
    ;;
Darwin)
    BUILD_ARCH=`uname -m`-unknown-darwin
    ;;
Cygwin)
    BUILD_ARCH=`uname -m`-unknown-cygwin
    ;;
*)
    BUILD_ARCH=
    echo "unknown host system!"
    exit 1
    ;;
esac

TOP_DIR="$PWD"
SRC_DIR="$TOP_DIR/src"
RULES_DIR="$TOP_DIR/rules"
BUILD_DIR="$TOP_DIR/build"
HOST_BUILD_DIR="$BUILD_DIR/host"
PATCH_DIR="$TOP_DIR/patches"
STATE_DIR="$TOP_DIR/state"
ROOTFS_DIR="$TOP_DIR/rootfs"
GENERICFS_DIR="$TOP_DIR/generic"

HOST_BIN_DIR="$TOP_DIR/host"
TARGET_BIN_DIR="$TOP_DIR/target"
TARGET_INC="$TARGET_BIN_DIR/include"
TARGET_LIB="$TARGET_BIN_DIR/lib"

IMAGES_DIR="$TOP_DIR/images"

download() {
    echo "Downloading $2"
    if [ ! -e "$SRC_DIR/$2" ]; then
        wget "$1/$2" -O "$SRC_DIR/$2" || error "Problem with download $2"
    fi
}

extract() {
    local src_d=${1/.*}
    test -e "$STATE_DIR/$src_d.extracted" && return
    echo "Extracting $1"
    case $1 in
    *.tar.gz|*.tgz)
	tar -zxf "$SRC_DIR/$1" -C "$BUILD_DIR" || error "Extract $1"
	;;
    *.tar.bz2|*.tbz2)
	tar -jxf "$SRC_DIR/$1" -C "$BUILD_DIR" || error "Extract $1"
	;;
    *)
	error "Unknown archive $1"
	;;
    esac
    touch "$STATE_DIR/$src_d.extracted" && return
}

extract_host() {
    local src_d=${1/.*}
    test -e "$STATE_DIR/host-${src_d}.extracted" && return
    echo "Extracting $1"
    case $1 in
    *.tar.gz|*.tgz)
	tar -zxf "$SRC_DIR/$1" -C "$HOST_BUILD_DIR" || error "Extract $1"
	;;
    *.tar.bz2|*.tbz2)
	tar -jxf "$SRC_DIR/$1" -C "$HOST_BUILD_DIR" || error "Extract $1"
	;;
    *)
	error "Unknown archive $1"
	;;
    esac
    touch "$STATE_DIR/host-${src_d}.extracted" && return
}

getfilename() {
    case $1 in
    *.tar.gz)
	echo ${1/.tar.gz}
	;;
    *.tgz)
	echo ${1/.tgz}
	;;
    *.tar.bz2)
	echo ${1/.tar.bz2}
	;;
    *.tbz2)
	echo ${1/.tbz2}
	;;
    *)
	echo $1
	;;
    esac
}

apply_patches()
{
    local src_d=`getfilename $2`
    test -e "$PATCH_DIR/$src_d/series" || return
    echo "Patching $2"
    local f=
    local o=
    pushd .
    cd "$1"
    cat $PATCH_DIR/$src_d/series | while read f ; do
	o=${f/* /}
	f=${f/ */}
	if [ "$f" = "$o" ]; then
	    o="-p1"
	fi
	echo "$PATCH_DIR/$src_d/$f | patch $o"
	case $f in
	*.gz)
	    zcat "$PATCH_DIR/$src_d/$f" | patch $o || error "patching $2"
	    ;;
	*.bz2)
	    bzcat "$PATCH_DIR/$src_d/$f" | patch $o || error "patching $2"
	    ;;
	*)
	    cat "$PATCH_DIR/$src_d/$f" | patch $o || error "patching $2"
	    ;;
	esac
    done
    popd
}

install_rc_start() {
    ln -sf ../init.d/${1} $ROOTFS_DIR/etc/rc.d/S${2}_${1}
}

install_rc_stop() {
    ln -sf ../init.d/${1} $ROOTFS_DIR/etc/rc.d/K${2}_${1}
}

install_sysroot_files() {
    local f=
    make DESTDIR=$TARGET_BIN_DIR install || error "installation in target sysroot"
#    for f in `find "$TARGET_BIN_DIR" -name "*.la" -type f`; do
#	sed -i -e "/^libdir=/s:\(libdir='\)\(/lib\|/usr/lib\):\1${TARGET_LIB}:g" $f
#    done
    sed -i -e "/^dependency_libs/s:\( \)\(/lib\|/usr/lib\):\1${TARGET_BIN_DIR}\2:g"	\
	    -e "/^libdir=/s:\(libdir='\)\(/lib\|/usr/lib\):\1${TARGET_BIN_DIR}\2:g"	\
	    `find ${TARGET_BIN_DIR} -name "*.la"`

    sed -i -e  "/^exec_prefix=/s:\(exec_prefix=\)\(/usr\):\1${TARGET_BIN_DIR}\2:g" 	\
	    -e "/^prefix=/s:\(prefix=\)\(/usr\):\1${TARGET_BIN_DIR}\2:g"		\
	    `find ${TARGET_BIN_DIR} -name "*.pc"`

    sed -i -e  "/^exec_prefix=/s:\(exec_prefix=\)\(/usr\):\1${TARGET_BIN_DIR}\2:g" 	\
	    -e "/^prefix=/s:\(prefix=\)\(/usr\):\1${TARGET_BIN_DIR}\2:g"		\
	    `find ${TARGET_BIN_DIR} -name "*-config"`

}

banner() {
    echo "*********************************************************************************"
    echo "$1"
}

mkdir -p "$SRC_DIR" || error mkdir
mkdir -p "$BUILD_DIR" || error mkdir
mkdir -p "$HOST_BUILD_DIR" || error mkdir
mkdir -p "$STATE_DIR" || error mkdir
mkdir -p "$ROOTFS_DIR" || error mkdir
mkdir -p "$HOST_BIN_DIR" || error mkdir
mkdir -p "$TARGET_BIN_DIR" || error mkdir
mkdir -p "$TARGET_INC" || error mkdir
mkdir -p "$TARGET_LIB" || error mkdir
mkdir -p "$IMAGES_DIR" || error mkdir

test -e "$TARGET_BIN_DIR/usr" || ln -sf . "$TARGET_BIN_DIR/usr"
#mkdir -p "$TARGET_BIN_DIR/usr" || error mkdir
#ln -sf ../../bin "$TARGET_BIN_DIR/usr/bin"
#ln -sf ../../lib "$TARGET_BIN_DIR/usr/lib"
#ln -sf ../../include "$TARGET_BIN_DIR/usr/include"

case $1 in
    clean)
	echo "Cleaning..."
	rm -rf "$BUILD_DIR"
	rm -rf "$STATE_DIR"
	rm -rf "$ROOTFS_DIR"
	rm -rf "$HOST_BIN_DIR"
	rm -rf "$TARGET_BIN_DIR"
	rm -rf "$IMAGES_DIR"
	exit 0
	;;
esac

if [ $HOST_SYSTEM = "Darwin" ]; then
    mkdir -p $HOST_BIN_DIR/bin
    CPIO=gnucpio
    which $CPIO 2>/dev/null >/dev/null || error "Please, install gnucpio utility."
    which gsed  2>/dev/null >/dev/null || error "Please, install sed utility."
    ln -sf `which $CPIO` $HOST_BIN_DIR/bin/cpio
    ln -sf `which gsed`  $HOST_BIN_DIR/bin/sed
    INSTALL=ginstall
else
    CPIO=cpio
    INSTALL=install
fi

STRIP=${CROSS}strip
DEPMOD=depmod

if [ "x$CROSS_OPT_CFLAGS" = "x" ]; then
    CROSS_OPT_CFLAGS="-O2"
fi

if [ "x$CROSS_OPT_CXXFLAGS" = "x" ]; then
    CROSS_OPT_CXXFLAGS="-O2"
fi

CROSS_CFLAGS="$CROSS_OPT_CFLAGS -isystem $TARGET_INC"
CROSS_CXXFLAGS="$CROSS_OPT_CXXFLAGS -isystem $TARGET_INC"
CROSS_CPPFLAGS="-isystem $TARGET_INC"
CROSS_LDFLAGS="-L$TARGET_LIB  -Wl,-rpath-link -Wl,$TARGET_LIB"
CROSS_CONF_ENV='CFLAGS="$CROSS_CFLAGS" CXXFLAGS="$CROSS_CXXFLAGS" LDFLAGS="$CROSS_LDFLAGS" CPPFLAGS="$CROSS_CPPFLAGS"'
CROSS_ENV_AC=" \
    ac_cv_func_getpgrp_void=yes \
    ac_cv_func_setpgrp_void=yes \
    ac_cv_func_memcmp_clean=yes \
    ac_cv_func_setvbuf_reversed=no \
    ac_cv_func_getrlimit=yes \
    ac_cv_type_uintptr_t=yes \
    ac_cv_func_posix_getpwuid_r=yes \
    ac_cv_func_posix_getgrgid_r=yes \
    ac_cv_func_dcgettext=yes \
    gt_cv_func_gettext_libintl=yes \
    ac_cv_sysv_ipc=yes \
    ac_cv_func_malloc_0_nonnull=yes \
"

HOST_CC=gcc
HOST_CXX=g++
HOST_PKG_CONFIG=`which pkg-config`

export PATH=$HOST_BIN_DIR/bin:$HOST_BIN_DIR/sbin:$TOOLCHAIN_PREFIX/bin:$PATH
export PKG_CONFIG_PATH=$TARGET_LIB/pkgconfig

echo "target arch $TARGET_ARCH"
echo "build  arch $HOST_ARCH"
