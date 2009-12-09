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

NSS_MAJOR_VERSION=3
NSS_MINOR_VERSION=12
NSS_PATCH_VERSION=3.1

NSS_VERSION=${NSS_MAJOR_VERSION}.${NSS_MINOR_VERSION}.${NSS_PATCH_VERSION}

NSS=nss-${NSS_VERSION}.tar.gz
NSS_MIRROR=https://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_3_12_3_1_RTM/src
NSS_DIR=$BUILD_DIR/nss-${NSS_VERSION}
NSS_ENV="$CROSS_ENV_AC"

build_nss() {
    test -e "$STATE_DIR/nss.installed" && return
    banner "Build nss"
    download $NSS_MIRROR $NSS
    extract $NSS
    apply_patches $NSS_DIR $NSS
    pushd $TOP_DIR
    cd $NSS_DIR
    local T_ARCH=
    local T_CONF=
    local USE_64=
    local OPT_CFLAGS="-O4"
    case $TARGET_ARCH in
	i386*|i486*|i586*|i686*)
	    T_ARCH="x86"
	    T_CONF="x86"
	    ;;
	arm*l-*)
	    T_ARCH="arm"
	    T_CONF="armel"
	    ;;
	arm*b-*)
	    T_ARCH="arm"
	    T_CONF="armeb"
	    ;;
	mipsel-*)
	    T_ARCH="mips"
	    T_CONF="mipsel"
	    OPT_CFLAGS='-O4 -freorder-blocks -fno-reorder-functions'
	    ;;
	mips*-*)
	    T_ARCH="mips"
	    T_CONF="mipseb"
	    OPT_CFLAGS='-O4 -freorder-blocks -fno-reorder-functions'
	    ;;
	mips64el-*)
	    T_ARCH="mips"
	    T_CONF="mips64el"
	    USE_64="USE_64=1"
	    OPT_CFLAGS='-O4 -freorder-blocks -fno-reorder-functions'
	    ;;
	mips64*-*)
	    T_ARCH="mips"
	    T_CONF="mips64eb"
	    USE_64="USE_64=1"
	    OPT_CFLAGS='-O4 -freorder-blocks -fno-reorder-functions'
	    ;;
	powerpc-*|ppc-*)
	    T_ARCH="ppc"
	    T_CONF="ppc"
	    OPT_CFLAGS='-O4 -freorder-blocks -fno-reorder-functions'
	    ;;
	powerpc64-*|ppc64-*)
	    T_ARCH="ppc"
	    T_CONF="ppc64"
	    USE_64="USE_64=1"
	    OPT_CFLAGS='-mminimal-toc -O4 -freorder-blocks -fno-reorder-functions'
	    ;;
	x86_64*|amd64*)
	    T_ARCH="x86_64"
	    T_CONF="x86_64"
	    USE_64="USE_64=1"
	    ;;
	*)
	    T_ARCH="${TARGET_ARCH/-*/}"
	    ;;
    esac
    #sed -i "s|CPU_ARCH =|CPU_ARCH = $T_ARCH|" mozilla/security/coreconf/Linux.mk

    local DISTDIR=${PWD}/mozilla/dist

    mkdir -p ${DISTDIR}

    $HOST_CC mozilla/security/coreconf/nsinstall/*.c -Imozilla/security/coreconf/nsinstall -o ${HOST_BIN_DIR}/bin/nsinstall || error "build host nsinstall"

    make \
	-C mozilla/security/nss \
		nss_build_all \
		MOZILLA_CLIENT=1 \
		NSPR_INCLUDE_DIR="`nspr-config --includedir`" \
		NSPR_LIB_DIR="`nspr-config --libdir`" \
		SOURCE_MD_DIR=${DISTDIR} \
		DIST=${DISTDIR} \
		BUILD_OPT=1 \
		NS_USE_GCC=1 \
		OPTIMIZER="${OPT_CFLAGS}" \
		NSS_USE_SYSTEM_SQLITE=1 \
		NSS_ENABLE_ECC=1 \
		CC=${CROSS}gcc \
		KERNEL=linux \
		CPU_ARCH=$T_ARCH \
		OS_TEST=$T_CONF \
		NSINSTALL=${HOST_BIN_DIR}/bin/nsinstall \
		${USE_64} \
    || error

    $INSTALL -m 644 -t ${ROOTFS_DIR}/usr/lib \
		${DISTDIR}/lib/libssl3.so \
		${DISTDIR}/lib/libsmime3.so \
		${DISTDIR}/lib/libnssutil3.so \
		${DISTDIR}/lib/libnss3.so

    mkdir -p ${ROOTFS_DIR}/usr/lib/nss

    $INSTALL -m 644 -t ${ROOTFS_DIR}/usr/lib/nss \
		${DISTDIR}/lib/libfreebl3.so \
		${DISTDIR}/lib/libsoftokn3.so \
		${DISTDIR}/lib/libnssdbm3.so \
		${DISTDIR}/lib/libnssckbi.so

    $STRIP \
		${ROOTFS_DIR}/usr/lib/libssl3.so \
		${ROOTFS_DIR}/usr/lib/libsmime3.so \
		${ROOTFS_DIR}/usr/lib/libnssutil3.so \
		${ROOTFS_DIR}/usr/lib/libnss3.so \
		${ROOTFS_DIR}/usr/lib/nss/libfreebl3.so \
		${ROOTFS_DIR}/usr/lib/nss/libsoftokn3.so \
		${ROOTFS_DIR}/usr/lib/nss/libnssdbm3.so \
		${ROOTFS_DIR}/usr/lib/nss/libnssckbi.so

    mkdir -p ${TARGET_INC}/include/nss

    $INSTALL -m 644 -t ${TARGET_INC}/nss \
		${DISTDIR}/public/nss/*
    $INSTALL -m 644 -t ${TARGET_LIB} \
		${DISTDIR}/lib/libcrmf.a \
		${DISTDIR}/lib/*.so

    echo "Install nss.pc"
    sed "s|@VERSION@|${NSS_VERSION}| ; s|@PREFIX@|${TARGET_BIN_DIR}|" ${GENERICFS_DIR}/nss/nss.pc.in > ${TARGET_LIB}/pkgconfig/nss.pc
    echo "Install nss-config"
    sed "s|@MOD_MAJOR_VERSION@|${NSS_MAJOR_VERSION}| ; s|@MOD_MINOR_VERSION@|${NSS_MINOR_VERSION}| ; s|@MOD_PATCH_VERSION@|${NSS_PATCH_VERSION}| ; s|@PREFIX@|${TARGET_BIN_DIR}|" \
	${GENERICFS_DIR}/nss/nss-config.in > ${TARGET_BIN_DIR}/bin/nss-config
    chmod 755 ${TARGET_BIN_DIR}/bin/nss-config
    ln -sf ${TARGET_BIN_DIR}/bin/nss-config ${HOST_BIN_DIR}/bin/nss-config

    popd
    touch "$STATE_DIR/nss.installed"
}

build_nss
