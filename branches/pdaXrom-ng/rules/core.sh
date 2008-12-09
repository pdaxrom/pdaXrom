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

TOP_DIR="$PWD"
SRC_DIR="$TOP_DIR/src"
RULES_DIR="$TOP_DIR/rules"
BUILD_DIR="$TOP_DIR/build"
HOST_BUILD_DIR="$BUILD_DIR/host"
PATCH_DIR="$TOP_DIR/patches"
STATE_DIR="$TOP_DIR/state"
ROOTFS_DIR="$TOP_DIR/rootfs"

HOST_BIN_DIR="$TOP_DIR/host"
TARGET_BIN_DIR="$TOP_DIR/target"

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

case $1 in
    clean)
	echo "Cleaning..."
	rm -rf "$BUILD_DIR"
	rm -rf "$STATE_DIR"
	rm -rf "$ROOTFS_DIR"
	rm -rf "$HOST_BIN_DIR"
	rm -rf "$TARGET_BIN_DIR"
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
else
    CPIO=cpio
fi

STRIP=${CROSS}strip
INSTALL=install

export PATH=$HOST_BIN_DIR/bin:$HOST_BIN_DIR/sbin:$TOOLCHAIN_PREFIX/bin:$PATH
