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

GNUMERIC_VERSION=1.10.5
GNUMERIC=gnumeric-${GNUMERIC_VERSION}.tar.bz2
GNUMERIC_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/gnumeric/1.10
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

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gnumeric.installed"
}

build_gnumeric
