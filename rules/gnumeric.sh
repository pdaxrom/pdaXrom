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

GNUMERIC_VERSION=1.8.4
GNUMERIC=gnumeric-${GNUMERIC_VERSION}.tar.bz2
GNUMERIC_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/gnumeric/1.8
GNUMERIC_DIR=$BUILD_DIR/gnumeric-${GNUMERIC_VERSION}
GNUMERIC_ENV="$CROSS_ENV_AC"

build_gnumeric() {
    test -e "$STATE_DIR/gnumeric.installed" && return
    banner "Build gnumeric"
    download $GNUMERIC_MIRROR $GNUMERIC
    extract $GNUMERIC
    apply_patches $GNUMERIC_DIR $GNUMERIC
    pushd $TOP_DIR
    cd $GNUMERIC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GNUMERIC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-ssconvert \
	    --disable-ssindex \
	    --disable-solver \
	    --without-gnome \
	    --without-gda \
	    --with-gb \
	    --without-psiconv \
	    --without-paradox \
	    --without-perl \
	    --without-python \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make $MAKEARGS DESTDIR=$GNUMERIC_DIR/fakeroot install || error

    rm -rf fakeroot/usr/include fakeroot/usr/lib/pkgconfig/ fakeroot/usr/lib/gnumeric/1.8.4/include
    rm -rf fakeroot/usr/share/gnome fakeroot/usr/share/locale fakeroot/usr/share/man

    find fakeroot/ -name "*.la" | xargs rm -f
    
    find fakeroot/ -type f -executable | xargs $STRIP

    cp -R fakeroot/usr $ROOTFS_DIR/ || error "copy target binaries"

    popd
    touch "$STATE_DIR/gnumeric.installed"
}

build_gnumeric
