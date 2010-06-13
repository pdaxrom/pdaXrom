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

GOFFICE_VERSION=0.8.5
GOFFICE=goffice-${GOFFICE_VERSION}.tar.bz2
GOFFICE_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/goffice/0.8
GOFFICE_DIR=$BUILD_DIR/goffice-${GOFFICE_VERSION}
GOFFICE_ENV="$CROSS_ENV_AC"

build_goffice() {
    test -e "$STATE_DIR/goffice.installed" && return
    banner "Build goffice"
    download $GOFFICE_MIRROR $GOFFICE
    extract $GOFFICE
    apply_patches $GOFFICE_DIR $GOFFICE
    pushd $TOP_DIR
    cd $GOFFICE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GOFFICE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --without-gnome \
	    --disable-gtk-doc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    sed -i -e 's|PluginDir=${libdir}|PluginDir=/usr/lib|' ${TARGET_LIB}/pkgconfig/libgoffice-0.8.pc

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/goffice.installed"
}

build_goffice
