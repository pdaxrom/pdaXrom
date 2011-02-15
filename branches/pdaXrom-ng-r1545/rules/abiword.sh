#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

ABIWORD_VERSION=2.8.5
ABIWORD=abiword-${ABIWORD_VERSION}.tar.gz
ABIWORD_MIRROR=http://www.abisource.com/downloads/abiword/${ABIWORD_VERSION}/source
ABIWORD_DIR=$BUILD_DIR/abiword-${ABIWORD_VERSION}
ABIWORD_ENV="$CROSS_ENV_AC"

build_abiword() {
    test -e "$STATE_DIR/abiword.installed" && return
    banner "Build abiword"
    download $ABIWORD_MIRROR $ABIWORD
    extract $ABIWORD
    apply_patches $ABIWORD_DIR $ABIWORD
    pushd $TOP_DIR
    cd $ABIWORD_DIR
    (
    case $TARGET_ARCH in
    powerpc64*|ppc64*)
	ABIWORD_ENV="$ABIWORD_ENV CFLAGS='-mminimal-toc -O3' CXXFLAGS='-mminimal-toc -O3'"
	;;
    esac

    eval \
	$CROSS_CONF_ENV \
	$ABIWORD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-pspell \
	    --disable-spellcheck \
	    --disable-printing \
	    --disable-exports \
	    --disable-cocoa \
	    --with-x \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/abiword.installed"
}

build_abiword
