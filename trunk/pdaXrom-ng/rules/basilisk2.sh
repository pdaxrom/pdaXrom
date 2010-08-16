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

BASILISK2_VERSION=0.9.20070407
BASILISK2=basilisk2_${BASILISK2_VERSION}.orig.tar.gz
BASILISK2_MIRROR=http://ftp.de.debian.org/debian/pool/contrib/b/basilisk2
BASILISK2_DIR=$BUILD_DIR/basilisk2
BASILISK2_ENV="$CROSS_ENV_AC
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

build_basilisk2() {
    test -e "$STATE_DIR/basilisk2.installed" && return
    banner "Build basilisk2"
    download $BASILISK2_MIRROR $BASILISK2
    extract $BASILISK2
    apply_patches $BASILISK2_DIR $BASILISK2
    pushd $TOP_DIR
    cd $BASILISK2_DIR/src/Unix
    chmod 755 configure
    (
    eval \
	$CROSS_CONF_ENV \
	$BASILISK2_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-x=no \
	    --with-esd=no \
	    --with-gtk=no \
	    --enable-sdl-video \
	    --enable-sdl-audio \
	    --enable-fbdev-dga=no \
	    -C \
	    || error
    ) || error "configure"

	# fixme
	echo "#define HAVE_SIGINFO_T 1" >> config.h

    make $MAKEARGS HOST_CC=gcc HOST_CXX=g++ || error

    #install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/basilisk2.installed"
}

build_basilisk2
