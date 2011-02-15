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

PHP_VERSION=5.3.2
PHP=php-${PHP_VERSION}.tar.bz2
PHP_MIRROR=http://dk.php.net/distributions
PHP_DIR=$BUILD_DIR/php-${PHP_VERSION}
PHP_ENV="$CROSS_ENV_AC"

build_php() {
    test -e "$STATE_DIR/php.installed" && return
    banner "Build php"
    download $PHP_MIRROR $PHP
    extract $PHP
    apply_patches $PHP_DIR $PHP
    pushd $TOP_DIR
    cd $PHP_DIR
    local PHP_CONF=""
    if [ ! "$PHP_LIBXPM" = "no" ]; then
	PHP_CONF="--with-xpm-dir=${TARGET_BIN_DIR}"
    fi
    (
    eval \
	$CROSS_CONF_ENV \
	$PHP_ENV \
	CC=${CROSS}gcc \
	./configure --build=$BUILD_ARCH --target=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --without-aolserver \
	    --without-apache \
	    --with-libxml-dir=${TARGET_BIN_DIR} \
	    --with-openssl=${TARGET_BIN_DIR} \
	    --with-pcre-regex=${TARGET_BIN_DIR} \
	    --with-sqlite3=${TARGET_BIN_DIR} \
	    --with-zlib=${TARGET_BIN_DIR} \
	    --enable-bcmath \
	    --with-bz2=${TARGET_BIN_DIR} \
	    --enable-calendar \
	    --with-curl=${TARGET_BIN_DIR} \
	    --with-jpeg-dir=${TARGET_BIN_DIR} \
	    --with-png-dir=${TARGET_BIN_DIR} \
	    --with-zlib-dir=${TARGET_BIN_DIR} \
	    --with-freetype-dir=${TARGET_BIN_DIR} \
	    --without-ldap \
	    --enable-mbstring \
	    --without-mssql \
	    --without-mysql \
	    --without-mysqli \
	    --with-sqlite3=${TARGET_BIN_DIR} \
	    --enable-sqlite-utf8 \
	    --enable-zip \
	    --without-iconv \
	    --disable-cli \
	    --disable-phar \
	    --with-gd=${TARGET_BIN_DIR} \
	    --enable-gd-native-ttf \
	    $PHP_CONF \
	    || error
    ) || error "configure"

    make $MAKEARGS CC=${CROSS}gcc || error

    #install_sysroot_files || error

    install_fakeroot_init INSTALL_ROOT=${PWD}/fakeroot

    rm -rf fakeroot/usr/lib/php/build
    rm -rf fakeroot/usr/bin/php-config

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/php.installed"
}

build_php
