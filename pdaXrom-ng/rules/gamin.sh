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

GAMIN_VERSION=0.1.10
GAMIN=gamin-${GAMIN_VERSION}.tar.bz2
GAMIN_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/gamin/0.1
GAMIN_DIR=$BUILD_DIR/gamin-${GAMIN_VERSION}
GAMIN_ENV="$CROSS_ENV_AC"

build_gamin() {
    test -e "$STATE_DIR/gamin.installed" && return
    banner "Build gamin"
    download $GAMIN_MIRROR $GAMIN
    extract $GAMIN
    apply_patches $GAMIN_DIR $GAMIN
    pushd $TOP_DIR
    cd $GAMIN_DIR
    (
    autoreconf -i
    sed -i -e 's:add_dir="-L$libdir"::g' ltmain.sh
    eval \
	$CROSS_CONF_ENV \
	$GAMIN_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB \
	    --without-python \
	    --disable-gtk-doc \
	    --disable-docs \
	    --libexecdir=/usr/lib/gamin
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gamin.installed"
}

build_gamin
