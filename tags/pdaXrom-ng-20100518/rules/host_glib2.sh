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

HOST_GLIB2=glib-2.22.0.tar.bz2
HOST_GLIB2_MIRROR=http://ftp.gtk.org/pub/glib/2.22
HOST_GLIB2_DIR=$HOST_BUILD_DIR/glib-2.22.0
HOST_GLIB2_ENV=

build_host_glib2() {
    test -e "$STATE_DIR/host_glib2.installed" && return
    banner "Build host-glib2"
    download $HOST_GLIB2_MIRROR $HOST_GLIB2
    extract_host $HOST_GLIB2
    apply_patches $HOST_GLIB2_DIR $HOST_GLIB2
    pushd $TOP_DIR
    cd $HOST_GLIB2_DIR
    (
     eval $HOST_GLIB2_ENV \
	CFLAGS="\"-I$HOST_BIN_DIR/include -fPIC\"" \
	LDFLAGS="-L$HOST_BIN_DIR/lib" \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error

    #for f in glib-genmarshal glib-mkenums gobject-query; do
    #	$INSTALL -D -m 755 gobject/$f $HOST_BIN_DIR/bin/$f || error
    #done

    #$INSTALL -D -m 755 glib-gettextize $HOST_BIN_DIR/bin/glib-gettextize || error

    popd
    touch "$STATE_DIR/host_glib2.installed"
}

build_host_glib2
