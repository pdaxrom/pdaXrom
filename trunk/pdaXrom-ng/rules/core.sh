#!/bin/bash

#
# pdaXrom-NG builder main functions
#
# Copyright (C) 2008,2009 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

error() {
    echo "ERROR: $1"
    exit 1
}

if [ "x$MAKEARGS" = "x" ]; then
    MAKEARGS=-j4
fi

if [ "x$CROSS" = "x" ]; then
    CROSS=${TARGET_ARCH}-
fi

if [ "x$TOOLCHAIN_LIBC_DIR" = "x" ]; then
    TOOLCHAIN_LIBC_DIR="${TOOLCHAIN_SYSROOT}/lib"
fi

HOST_SYSTEM=`uname`
HOST_ARCH=`uname -m`

if [ "$HOST_SYSTEM" = "Darwin" -a "$HOST_ARCH" = "i386" ]; then
    if test echo | cpp -v 2>&1| grep "\-m64" >/dev/null ; then
	HOST_ARCH="x86_64"
    fi
fi

BUILD_ARCH=
case $HOST_SYSTEM in
Linux)
    BUILD_ARCH=${HOST_ARCH}-unknown-linux
    ;;
Darwin)
    BUILD_ARCH=${HOST_ARCH}-unknown-darwin
    ;;
CYGWIN*)
    BUILD_ARCH=${HOST_ARCH}-unknown-cygwin
    HOST_SYSTEM="CYGWIN"
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
CONFIG_DIR="$TOP_DIR/configs"

HOST_BIN_DIR="$TOP_DIR/host"
TARGET_BIN_DIR="$TOP_DIR/target"
TARGET_INC="$TARGET_BIN_DIR/include"
TARGET_LIB="$TARGET_BIN_DIR/lib"

IMAGES_DIR="$TOP_DIR/images"

DOWNLOAD_MIRROR="http://mail.pdaXrom.org/downloads/src"

download2() {
    echo "Downloading $1 from mirror $DOWNLOAD_MIRROR"
    wget -c "$DOWNLOAD_MIRROR/$1" -O "$SRC_DIR/$1"
    if [ "$?" != "0" ]; then
	rm -f "$SRC_DIR/$1"
	error "Problem download $1"
    fi
}

#
# download <url> <file>
#
download() {
    echo "Downloading $2"
    if [ ! -e "$SRC_DIR/$2" ]; then
        wget "$1/$2" -O "$SRC_DIR/$2" || download2 $2
    fi
}

#
# download_svn <url> <source name>
#
download_svn() {
    if [ ! -d $SRC_DIR/$2/.svn ]; then
	echo "Download sources"
	svn co $1 $SRC_DIR/$2
    else
	echo "Update sources"
	pushd $TOP_DIR
	cd $SRC_DIR/$2
	svn update || error
	popd
    fi
}

#
# download_git <git> <source name> [<revision>]
#
download_git() {
    if [ ! -d $SRC_DIR/$2/.git ]; then
	echo "Download sources"
	git-clone $1 $SRC_DIR/$2 || error "Download sources"
	if [ ! "x$3" = "x" ]; then
	    pushd $TOP_DIR
	    cd $SRC_DIR/$2
	    git-checkout $3 || error "Checkout revision"
	    popd
	fi
    elif [ "x$3" = "x" ]; then
	echo "Update sources"
	pushd $TOP_DIR
	cd $SRC_DIR/$2
	git-pull || echo "update problem"
	popd
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
	if [ -e $SRC_DIR/$1 ]; then
	    cp -R $SRC_DIR/$1 $BUILD_DIR/ || error "Copy sources $1"
	else
	    error "Unknown archive $1"
	fi
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
	if [ -e $SRC_DIR/$1 ]; then
	    cp -R $SRC_DIR/$1 $HOST_BUILD_DIR/ || error "Copy sources $1"
	else
	    error "Unknown archive $1"
	fi
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

apply_patches1()
{
    local src_d=$2
    
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
	test -e $PATCH_DIR/$src_d/$f -a ! -d $PATCH_DIR/$src_d/$f || continue
	echo "*** $PATCH_DIR/$src_d/$f  patch $o"
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

apply_patches() {
    test -e "$1/.pdaXrom-ng-patched" && return

    # hack! remove hardcoded libdir
    test -e $1/ltmain.sh && sed -i -e 's:add_dir="-L$libdir"::g' $1/ltmain.sh

    local src_d=`getfilename $2`

    apply_patches1 $1 $src_d
    
    if [ ! "x$TARGET_VENDOR_PATCH" = "x" ]; then
	src_d="${src_d}-${TARGET_VENDOR_PATCH}"
	apply_patches1 $1 $src_d
    fi

    touch "$1/.pdaXrom-ng-patched"
}

install_rc_start() {
    ln -sf ../init.d/${1} $ROOTFS_DIR/etc/rc.d/S${2}_${1}
}

install_rc_stop() {
    ln -sf ../init.d/${1} $ROOTFS_DIR/etc/rc.d/K${2}_${1}
}

install_sysroot_files() {
    local f=
    make DESTDIR=$TARGET_BIN_DIR $@ install || error "installation in target sysroot"
#    for f in `find "$TARGET_BIN_DIR" -name "*.la" -type f`; do
#	sed -i -e "/^libdir=/s:\(libdir='\)\(/lib\|/usr/lib\):\1${TARGET_LIB}:g" $f
#    done
    sed -i -e "/^dependency_libs/s:\( \)\(/lib\|/usr/lib\):\1${TARGET_BIN_DIR}\2:g"	\
	    -e "/^libdir=/s:\(libdir='\)\(/lib\|/usr/lib\):\1${TARGET_BIN_DIR}\2:g"	\
	    `find ${TARGET_BIN_DIR} -name "*.la"` || true

    sed -i -e  "/^exec_prefix=/s:\(exec_prefix=\)\(/usr\):\1${TARGET_BIN_DIR}\2:g" 	\
	    -e "/^prefix=/s:\(prefix=\)\(/usr\):\1${TARGET_BIN_DIR}\2:g"		\
	    -e "/^libdir=/s:\(libdir=\)\(/lib\|/usr/lib\):\1${TARGET_BIN_DIR}\2:g"	\
	    `find ${TARGET_BIN_DIR} -name "*.pc"` || true

    sed -i -e  "/^exec_prefix=/s:\(exec_prefix=\)\(/usr\):\1${TARGET_BIN_DIR}\2:g" 	\
	    -e "/^prefix=/s:\(prefix=\)\(/usr\):\1${TARGET_BIN_DIR}\2:g"		\
	    `find ${TARGET_BIN_DIR} -name "*-config"` || true
}

banner() {
    echo
    echo "*********************************************************************************"
    echo "$1"
    echo
    if [ "$TERM" = "xterm-color" -o "$TERM" = "xterm" ]; then
	echo -ne "\033]0;${1}\007"
    fi
}

install_gcc_wrappers() {
    mkdir -p $HOST_BIN_DIR/bin
    for f in c++ cc cpp g++ gcc; do
	test -e $TOOLCHAIN_PREFIX/bin/${TARGET_ARCH}-${f} || continue
	echo "#!/bin/sh" > $HOST_BIN_DIR/bin/${TARGET_ARCH}-${f}
	echo "exec $TOOLCHAIN_PREFIX/bin/${TARGET_ARCH}-${f} ${CROSS_OPT_ARCH} -isystem ${TARGET_INC} \${1+\"\$@\"}" >> $HOST_BIN_DIR/bin/${TARGET_ARCH}-${f}
	chmod 755 $HOST_BIN_DIR/bin/${TARGET_ARCH}-${f}
    done
}

install_rootfs_usr_lib() {
    local f=`basename $1`
    local f1=`echo $f | sed -e "s/.so.*//"`
    echo "Installing $f1 /$f/"
    local s=`echo $1 | sed -e "s/^.*so\.//g" | cut -f1 -d'.'`
    $INSTALL -D -m 644 $1 ${ROOTFS_DIR}/usr/lib/${f} || error
    ln -sf ${f} ${ROOTFS_DIR}/usr/lib/${f1}.so.${s} || error
    ln -sf ${f} ${ROOTFS_DIR}/usr/lib/${f1}.so || error
    $STRIP ${ROOTFS_DIR}/usr/lib/${f} || error
}

install_rootfs_usr_bin() {
    local f=`basename $1`
    $INSTALL -D -m 755 $1 ${ROOTFS_DIR}/usr/bin/$f || error
    $STRIP ${ROOTFS_DIR}/usr/bin/$f || error
}

install_rootfs_usr_sbin() {
    local f=`basename $1`
    $INSTALL -D -m 755 $1 ${ROOTFS_DIR}/usr/sbin/$f || error
    $STRIP ${ROOTFS_DIR}/usr/sbin/$f || error
}

install_fakeroot_init() {
    local faked=$PWD/fakeroot
    make DESTDIR=${faked} $@ install || error
    rm -rf ${faked}/usr/include ${faked}/usr/lib/pkgconfig
    rm -rf ${faked}/usr/share/aclocal
    rm -rf ${faked}/usr/share/doc
    rm -rf ${faked}/usr/share/doc-base
    rm -rf ${faked}/usr/share/gtk-doc
    rm -rf ${faked}/usr/share/locale
    rm -rf ${faked}/usr/share/man
    rm -rf ${faked}/usr/share/info
    rm -rf ${faked}/usr/man
    rm -rf ${faked}/usr/info
    find ${faked} -name "*.la" -exec rm -f {} \;
    find ${faked} -name "*.a"  -exec rm -f {} \;
    find ${faked} -not -type d | while read f; do
	file $f | grep -q "ELF " && $STRIP $f
    done
}

install_fakeroot_usr_lib() {
    local f=`basename $1`
    local f1=`echo $f | sed -e "s/.so.*//"`
    echo "Installing $f1 /$f/"
    local s=`echo $1 | sed -e "s/^.*so\.//g" | cut -f1 -d'.'`
    $INSTALL -D -m 644 $1 fakeroot/usr/lib/${f} || error
    ln -sf ${f} fakeroot/usr/lib/${f1}.so.${s} || error
    ln -sf ${f} fakeroot/usr/lib/${f1}.so || error
    $STRIP fakeroot/usr/lib/${f} || error
}

install_fakeroot_usr_bin() {
    local f=`basename $1`
    $INSTALL -D -m 755 $1 fakeroot/usr/bin/$f || error
    $STRIP fakeroot/usr/bin/$f || error
}

install_fakeroot_usr_sbin() {
    local f=`basename $1`
    $INSTALL -D -m 755 $1 fakeroot/usr/sbin/$f || error
    $STRIP fakeroot/usr/sbin/$f || error
}

install_fakeroot_finish() {
    tar c -C fakeroot . | tar x -C ${ROOTFS_DIR} || error
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

if [ -e ${TOOLCHAIN_SYSROOT}/lib64 ]; then
    ln -sf lib ${TARGET_BIN_DIR}/lib64
elif [ -e ${TOOLCHAIN_SYSROOT}/lib32 ]; then
    ln -sf lib ${TARGET_BIN_DIR}/lib32
fi

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
    export PATH=$PATH:/opt/local/bin:/opt/local/sbin:/usr/X11R6/bin
    mkdir -p $HOST_BIN_DIR/bin
    CPIO=gnucpio
    which $CPIO 2>/dev/null >/dev/null || error "Please, install cpio."
    which gsed  2>/dev/null >/dev/null || error "Please, install gsed."
    which glibtoolize 2>/dev/null >/dev/null || error "Please, install libtool."
    ln -sf `which $CPIO` $HOST_BIN_DIR/bin/cpio
    ln -sf `which gsed`  $HOST_BIN_DIR/bin/sed
    ln -sf `which glibtoolize` $HOST_BIN_DIR/bin/libtoolize
    INSTALL=ginstall
else
    CPIO=cpio
    INSTALL=install
fi

if [ $HOST_SYSTEM = "CYGWIN" ]; then
    HOST_EXE_SUFFIX=".exe"
else
    HOST_EXE_SUFFIX=
fi

install_gcc_wrappers

which ${TOOLCHAIN_PREFIX}/bin/${CROSS}gcc >/dev/null && ln -sf `${TOOLCHAIN_PREFIX}/bin/${CROSS}gcc -print-file-name=libstdc++.so` ${TARGET_LIB}/libstdc++.so.6

STRIP="${CROSS}strip -R .note -R .comment"
DEPMOD=depmod

CROSS_CFLAGS="$CROSS_OPT_CFLAGS"
CROSS_CXXFLAGS="$CROSS_OPT_CXXFLAGS"
CROSS_CPPFLAGS="$CROSS_OPT_CPPFLAGS"
CROSS_LDFLAGS="-L$TARGET_LIB  -Wl,-rpath-link -Wl,$TARGET_LIB"
#CROSS_CONF_ENV='CFLAGS="$CROSS_CFLAGS" CXXFLAGS="$CROSS_CXXFLAGS" LDFLAGS="$CROSS_LDFLAGS" CPPFLAGS="$CROSS_CPPFLAGS"'
CROSS_CONF_ENV='LDFLAGS="$CROSS_LDFLAGS"'

if [ ! "x$CROSS_CFLAGS" = "x" ]; then
    CROSS_CONF_ENV="$CROSS_CONF_ENV CFLAGS=\"$CROSS_CFLAGS\""
fi
if [ ! "x$CROSS_CXXFLAGS" = "x" ]; then
    CROSS_CONF_ENV="$CROSS_CONF_ENV CXXFLAGS=\"$CROSS_CXXFLAGS\""
fi
if [ ! "x$CROSS_CPPFLAGS" = "x" ]; then
    CROSS_CONF_ENV="$CROSS_CONF_ENV CPPFLAGS=\"$CROSS_CPPFLAGS\""
fi

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
HOST_CPPFLAGS="-I$HOST_BIN_DIR/include"
HOST_LDFLAGS="-L$HOST_BIN_DIR/lib -Wl,-rpath -Wl,$HOST_BIN_DIR/lib"

if [ $HOST_SYSTEM = "Darwin" ]; then
    HOST_CPPFLAGS="$HOST_CPPFLAGS -I/opt/local/include"
    HOST_LDFLAGS="$HOST_LDFLAGS -L/opt/local/lib"
fi

export PATH=$HOST_BIN_DIR/bin:$HOST_BIN_DIR/sbin:$TOOLCHAIN_PREFIX/bin:$PATH
export PKG_CONFIG_PATH=$TARGET_LIB/pkgconfig

echo "target arch $TARGET_ARCH"
echo "build  arch $BUILD_ARCH"

trap "banner ''" 2
