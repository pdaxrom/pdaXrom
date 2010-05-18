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

BOOST_VERSION=1_41_0
BOOST=boost_${BOOST_VERSION}.tar.bz2
BOOST_MIRROR=http://downloads.sourceforge.net/project/boost/boost/1.41.0
BOOST_DIR=$BUILD_DIR/boost_${BOOST_VERSION}
BOOST_ENV="$CROSS_ENV_AC"

build_boost() {
    test -e "$STATE_DIR/boost.installed" && return
    banner "Build boost"
    download $BOOST_MIRROR $BOOST
    extract $BOOST
    apply_patches $BOOST_DIR $BOOST
    pushd $TOP_DIR
    cd $BOOST_DIR

    mkdir -p ${BOOST_DIR}/xbin
    for f in c++ cc cpp g++ gcc; do
	test -e $TOOLCHAIN_PREFIX/bin/${TARGET_ARCH}-${f} || continue
	echo "#!/bin/sh" > ${BOOST_DIR}/xbin/${f}
	echo "exec $TOOLCHAIN_PREFIX/bin/${TARGET_ARCH}-${f} ${CROSS_OPT_ARCH} -L${TARGET_LIB} -isystem ${TARGET_INC} \${1+\"\$@\"}" >> ${BOOST_DIR}/xbin/${f}
	chmod 755 ${BOOST_DIR}/xbin/${f}
    done

    ./bootstrap.sh || error "bootstrapping"

    PATH=${BOOST_DIR}/xbin:${TOOLCHAIN_PREFIX}/xbin:$PATH ./bjam -j4 --build-type=minimal --layout=system --without-python || error "build"

    ln -sf ${BOOST_DIR}/boost $TARGET_INC
    cp -a stage/lib/* $TARGET_LIB

    mkdir -p fakeroot/usr
    cp -a stage/lib fakeroot/usr
    rm -f fakeroot/usr/lib/*.a
    ${STRIP} fakeroot/usr/lib/*.so*

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/boost.installed"
}

build_boost
