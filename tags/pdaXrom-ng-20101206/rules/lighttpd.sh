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

LIGHTTPD_VERSION=1.4.26
LIGHTTPD=lighttpd-${LIGHTTPD_VERSION}.tar.bz2
LIGHTTPD_MIRROR=http://download.lighttpd.net/lighttpd/releases-1.4.x
LIGHTTPD_DIR=$BUILD_DIR/lighttpd-${LIGHTTPD_VERSION}
LIGHTTPD_ENV="$CROSS_ENV_AC"

build_lighttpd() {
    test -e "$STATE_DIR/lighttpd.installed" && return
    banner "Build lighttpd"
    download $LIGHTTPD_MIRROR $LIGHTTPD
    extract $LIGHTTPD
    apply_patches $LIGHTTPD_DIR $LIGHTTPD
    pushd $TOP_DIR
    cd $LIGHTTPD_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIGHTTPD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --without-mysql \
	    --without-ldap \
	    --with-openssl \
	    --without-kerberos5 \
	    --with-zlib \
	    --with-bzip2 \
	    --with-fam \
	    --with-webdav-props \
	    --with-webdav-locks \
	    --without-gdbm \
	    --without-memcache \
	    --without-lua \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init

    $INSTALL -D -m 644 $GENERICFS_DIR/lighttpd/lighttpd.conf fakeroot/etc/lighttpd/lighttpd.conf
    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/lighttpd fakeroot/etc/init.d/lighttpd
    mkdir -p fakeroot/var/log/lighttpd
    mkdir -p fakeroot/var/www/htdocs
    install_fakeroot_finish || error

    install_rc_start lighttpd 60
    install_rc_stop  lighttpd 40

    popd
    touch "$STATE_DIR/lighttpd.installed"
}

build_lighttpd
