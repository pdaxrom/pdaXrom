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

SHEEPSHAVER_VERSION=2.3
SHEEPSHAVER=SheepShaver-${SHEEPSHAVER_VERSION}-0.20060514.1.tar.bz2
SHEEPSHAVER_MIRROR=http://www.gibix.net/projects/sheepshaver/files
SHEEPSHAVER_DIR=$BUILD_DIR/SheepShaver-${SHEEPSHAVER_VERSION}
SHEEPSHAVER_ENV="$CROSS_ENV_AC
ac_cv_linker_script_works=no
ac_cv_file__dev_ptc=no
ac_cv_have_byte_bitfields=yes
ac_cv_have_extended_signals=yes
ac_cv_have_skip_instruction=yes
ac_cv_mmap_anon=yes
ac_cv_mmap_anonymous=yes
ac_cv_mprotect_works=yes
ac_cv_sigaction_need_reinstall=no
ac_cv_signal_need_reinstall=no
sigsegv_recovery=siginfo
"

build_SheepShaver() {
    test -e "$STATE_DIR/SheepShaver.installed" && return
    banner "Build SheepShaver"
    download $SHEEPSHAVER_MIRROR $SHEEPSHAVER
    extract $SHEEPSHAVER
    apply_patches $SHEEPSHAVER_DIR $SHEEPSHAVER
    pushd $TOP_DIR
    local C_ARGS=
    case $TARGET_ARCH in
    powerpc*-uclibc*|ppc*-uclibc*)
		C_ARGS="--enable-jit=no --enable-ppc-emulator"
		;;
    powerpc*|ppc*)
		C_ARGS="--enable-jit=no --enable-ppc-emulator"
		SHEEPSHAVER_ENV="$SHEEPSHAVER_ENV CFLAGS='-O3 -fomit-frame-pointer -mtune=cell' CXXFLAGS='-O3 -fomit-frame-pointer -mtune=cell'"
		;;
    esac
    cd $SHEEPSHAVER_DIR/src/Unix
    (
    eval \
	$CROSS_CONF_ENV \
	$SHEEPSHAVER_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-sdl-audio \
	    --enable-sdl-video \
	    --with-x=no \
	    --with-gtk=no \
	    --with-esd=no \
	    $C_ARGS \
	    || error
    ) || error "configure"

	# fixme
	echo "#define HAVE_SIGINFO_T 1" >> config.h

    make $MAKEARGS AS=${CROSS}as DYNGEN_CC=gcc || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error
	$INSTALL -D -m 755 ${GENERICFS_DIR}/basilisk2/SheepShaver-fb ${ROOTFS_DIR}/usr/bin/SheepShaver-fb

    popd
    touch "$STATE_DIR/SheepShaver.installed"
}

build_SheepShaver
