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

HOST_GETTEXT=gettext-0.17.tar.gz
HOST_GETTEXT_MIRROR=http://ftp.gnu.org/pub/gnu/gettext
HOST_GETTEXT_DIR=$HOST_BUILD_DIR/gettext-0.17
HOST_GETTEXT_ENV=

if [ "$HOST_SYSTEM" = "Linux" ]; then
    HOST_GETTEXT_ENV="CFLAGS='-O2 -D_FORTIFY_SOURCE=0' $HOST_GETTEXT_ENV"
fi

build_host_gettext() {
    test -e "$STATE_DIR/host_gettext.installed" && return
    banner "Build host-gettext"
    download $HOST_GETTEXT_MIRROR $HOST_GETTEXT
    extract_host $HOST_GETTEXT
    apply_patches $HOST_GETTEXT_DIR $HOST_GETTEXT
    pushd $TOP_DIR
    cd $HOST_GETTEXT_DIR
    (
     eval $HOST_GETTEXT_ENV \
	./configure --prefix=$HOST_BIN_DIR \
	    --disable-java \
	    --disable-native-java \
	    --disable-csharp
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_gettext.installed"
}

build_host_gettext
