#
# host packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_INTLTOOL=intltool-0.40.5.tar.bz2
HOST_INTLTOOL_MIRROR=http://ftp.gnome.org/pub/gnome/sources/intltool/0.40
HOST_INTLTOOL_DIR=$HOST_BUILD_DIR/intltool-0.40.5
HOST_INTLTOOL_ENV=

build_host_intltool() {
    test -e "$STATE_DIR/host_intltool.installed" && return
    banner "Build host-intltool"
    download $HOST_INTLTOOL_MIRROR $HOST_INTLTOOL
    extract_host $HOST_INTLTOOL
    apply_patches $HOST_INTLTOOL_DIR $HOST_INTLTOOL
    pushd $TOP_DIR
    cd $HOST_INTLTOOL_DIR
    eval $HOST_INTLTOOL_ENV \
	./configure --prefix=$HOST_BIN_DIR \
	    || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_intltool.installed"
}

build_host_intltool
