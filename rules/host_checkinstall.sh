#
# host packet template
#
# Copyright (C) 2009 by Adrian Crutchfield <insearchof@inventgen-solutions.com>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_CHECKINSTALL_VERSION=1.6.2
HOST_CHECKINSTALL=checkinstall-${HOST_CHECKINSTALL_VERSION}.tar.gz
HOST_CHECKINSTALL_MIRROR=http://asic-linux.com.mx/%7Eizto/checkinstall/files/source/
HOST_CHECKINSTALL_DIR=$HOST_BUILD_DIR/checkinstall-${HOST_CHECKINSTALL_VERSION}
HOST_CHECKINSTALL_ENV=

build_host_checkinstall() {
    test -e "$STATE_DIR/host_checkinstall.installed" && return
    banner "Build host-checkinstall"
    download $HOST_CHECKINSTALL_MIRROR $HOST_CHECKINSTALL
    extract_host $HOST_CHECKINSTALL
    apply_patches $HOST_CHECKINSTALL_DIR $HOST_CHECKINSTALL
    pushd $TOP_DIR
    cd $HOST_CHECKINSTALL_DIR
#    (
#    eval $HOST_CHECKINSTALL_ENV \
#	./configure --prefix=$HOST_BIN_DIR
#   ) || error 
    sed -i -e s:PREFIX=/usr/local:PREFIX=`echo $HOST_BIN_DIR`:g ./Makefile 
    sed -i -e s:PREFIX=/usr/local:PREFIX=`echo $HOST_BIN_DIR`:g ./installwatch/Makefile
    unset $PATH
    make || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_checkinstall.installed"
}

build_host_checkinstall
