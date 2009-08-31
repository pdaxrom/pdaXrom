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

TARGET_BASH_VERSION=4.0
TARGET_BASH=bash-${TARGET_BASH_VERSION}.tar.gz
TARGET_BASH_MIRROR=http://ftp.gnu.org/gnu/bash
TARGET_BASH_DIR=$BUILD_DIR/bash-${TARGET_BASH_VERSION}
TARGET_BASH_ENV="$CROSS_ENV_AC \
bash_cv_job_control_missing=no \
bash_cv_func_ctype_nonascii=yes \
bash_cv_sys_siglist=yes \
bash_cv_decl_under_sys_siglist=yes \
bash_cv_under_sys_siglist=yes"

build_target_bash() {
    test -e "$STATE_DIR/target_bash.installed" && return
    banner "Build target-bash"
    download $TARGET_BASH_MIRROR $TARGET_BASH
    extract $TARGET_BASH
    apply_patches $TARGET_BASH_DIR $TARGET_BASH
    pushd $TOP_DIR
    cd $TARGET_BASH_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TARGET_BASH_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/bash \
	    --enable-largefile \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init || error
    mkdir -p fakeroot/bin
    mv -f fakeroot/usr/bin/bash fakeroot/bin/
    ln -sf bash fakeroot/bin/sh
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/target_bash.installed"
}

build_target_bash
