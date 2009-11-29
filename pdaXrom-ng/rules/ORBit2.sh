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

ORBIT2_VERSION=2.14.17
ORBIT2=ORBit2-${ORBIT2_VERSION}.tar.bz2
ORBIT2_MIRROR=ftp://ftp.gnome.org/pub/GNOME/sources/ORBit2/2.14
ORBIT2_DIR=$BUILD_DIR/ORBit2-${ORBIT2_VERSION}
ORBIT2_ENV="$CROSS_ENV_AC"

case $TARGET_ARCH in
arm*)
	ORBIT2_ENV="$ORBIT2_ENV \
	ac_cv_alignof_CORBA_boolean=1 \
	ac_cv_alignof_CORBA_char=1 \
	ac_cv_alignof_CORBA_double=8 \
	ac_cv_alignof_CORBA_float=4 \
	ac_cv_alignof_CORBA_long=4 \
	ac_cv_alignof_CORBA_long_double=8 \
	ac_cv_alignof_CORBA_long_long=8 \
	ac_cv_alignof_CORBA_octet=1 \
	ac_cv_alignof_CORBA_pointer=4 \
	ac_cv_alignof_CORBA_short=2 \
	ac_cv_alignof_CORBA_struct=1 \
	ac_cv_alignof_CORBA_wchar=2"
	;;
mips*)
	ORBIT2_ENV="$ORBIT2_ENV \
	ac_cv_alignof_CORBA_boolean=1 \
	ac_cv_alignof_CORBA_char=1 \
	ac_cv_alignof_CORBA_double=8 \
	ac_cv_alignof_CORBA_float=4 \
	ac_cv_alignof_CORBA_long=4 \
	ac_cv_alignof_CORBA_long_double=8 \
	ac_cv_alignof_CORBA_long_long=8 \
	ac_cv_alignof_CORBA_octet=1 \
	ac_cv_alignof_CORBA_pointer=4 \
	ac_cv_alignof_CORBA_short=2 \
	ac_cv_alignof_CORBA_struct=1 \
	ac_cv_alignof_CORBA_wchar=2"
	;;
ppc-*|powerpc-*)
	ORBIT2_ENV="$ORBIT2_ENV \
	ac_cv_alignof_CORBA_boolean=1 \
	ac_cv_alignof_CORBA_char=1 \
	ac_cv_alignof_CORBA_double=8 \
	ac_cv_alignof_CORBA_float=4 \
	ac_cv_alignof_CORBA_long=4 \
	ac_cv_alignof_CORBA_long_double=8 \
	ac_cv_alignof_CORBA_long_long=8 \
	ac_cv_alignof_CORBA_octet=1 \
	ac_cv_alignof_CORBA_pointer=4 \
	ac_cv_alignof_CORBA_short=2 \
	ac_cv_alignof_CORBA_struct=1 \
	ac_cv_alignof_CORBA_wchar=2"
	;;
ppc64-*|powerpc64-*)
	ORBIT2_ENV="$ORBIT2_ENV \
	ac_cv_alignof_CORBA_boolean=1 \
	ac_cv_alignof_CORBA_char=1 \
	ac_cv_alignof_CORBA_double=8 \
	ac_cv_alignof_CORBA_float=4 \
	ac_cv_alignof_CORBA_long=4 \
	ac_cv_alignof_CORBA_long_double=8 \
	ac_cv_alignof_CORBA_long_long=8 \
	ac_cv_alignof_CORBA_octet=1 \
	ac_cv_alignof_CORBA_pointer=8 \
	ac_cv_alignof_CORBA_short=2 \
	ac_cv_alignof_CORBA_struct=1 \
	ac_cv_alignof_CORBA_wchar=2"
	;;
i*86-*)
	ORBIT2_ENV="$ORBIT2_ENV \
	ac_cv_alignof_CORBA_boolean=1 \
	ac_cv_alignof_CORBA_char=1 \
	ac_cv_alignof_CORBA_double=8 \
	ac_cv_alignof_CORBA_float=4 \
	ac_cv_alignof_CORBA_long=4 \
	ac_cv_alignof_CORBA_long_double=8 \
	ac_cv_alignof_CORBA_long_long=8 \
	ac_cv_alignof_CORBA_octet=1 \
	ac_cv_alignof_CORBA_pointer=4 \
	ac_cv_alignof_CORBA_short=2 \
	ac_cv_alignof_CORBA_struct=1 \
	ac_cv_alignof_CORBA_wchar=2"
	;;
x86_64-*)
	ORBIT2_ENV="$ORBIT2_ENV \
	ac_cv_alignof_CORBA_boolean=1 \
	ac_cv_alignof_CORBA_char=1 \
	ac_cv_alignof_CORBA_double=8 \
	ac_cv_alignof_CORBA_float=4 \
	ac_cv_alignof_CORBA_long=4 \
	ac_cv_alignof_CORBA_long_double=8 \
	ac_cv_alignof_CORBA_long_long=8 \
	ac_cv_alignof_CORBA_octet=1 \
	ac_cv_alignof_CORBA_pointer=8 \
	ac_cv_alignof_CORBA_short=2 \
	ac_cv_alignof_CORBA_struct=1 \
	ac_cv_alignof_CORBA_wchar=2"
	;;
esac

build_ORBit2() {
    test -e "$STATE_DIR/ORBit2.installed" && return
    banner "Build ORBit2"
    download $ORBIT2_MIRROR $ORBIT2
    extract $ORBIT2
    apply_patches $ORBIT2_DIR $ORBIT2
    pushd $TOP_DIR
    cd $ORBIT2_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ORBIT2_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-pic \
	    || error
    ) || error "configure"

    make $MAKEARGS IDL_COMPILER=${HOST_BIN_DIR}/bin/orbit-idl-2 || error

    install_sysroot_files || error

    install_fakeroot_init

    rm -rf fakeroot/usr/bin
    rm -rf fakeroot/usr/share/idl

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/ORBit2.installed"
}

build_ORBit2
