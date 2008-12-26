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

ICU4C=icu4c-4_1_1-src.tgz
ICU4C_MIRROR=http://download.icu-project.org/files/icu4c/4.1
ICU4C_DIR=$BUILD_DIR/icu/source
ICU4C_ENV="$CROSS_ENV_AC"

build_icu4c() {
    test -e "$STATE_DIR/icu4c.installed" && return
    banner "Build icu4c"
    download $ICU4C_MIRROR $ICU4C
    extract $ICU4C
    apply_patches $ICU4C_DIR/.. $ICU4C
    pushd $TOP_DIR
    cd $ICU4C_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ICU4C_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    for i in */Makefile */*.inc */*/Makefile */*/*.inc ; do
	sed -i -e 's:$(INVOKE) $(BINDIR)/:$(INVOKE) :g' $i
	sed -i -e 's:$(BINDIR)/::g' $i
    done
    sed -i -e 's:$(BINDIR)/::g' extra/uconv/pkgdata.inc || true
    sed -i -e 's:$(BINDIR)/::g' extra/uconv/pkgdata.inc.in || true
    sed -i -e 's:$(CROSS_PKGDATA_MAKEARGS):TARGET="libicudata.so":g' data/Makefile || true
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    sed -i -e "s:^prefix=:prefix=$TARGET_BIN_DIR:g" $TARGET_BIN_DIR/bin/icu-config

    ln -sf $TARGET_BIN_DIR/bin/icu-config $HOST_BIN_DIR/bin/ || error

    for f in libicudata libicui18n libicuio libicule libiculx libicutu libicuuc; do
	$INSTALL -D -m 644 lib/$f.so.41.1 $ROOTFS_DIR/usr/lib/$f.so.41.1 || error
	ln -sf $f.so.41.1 $ROOTFS_DIR/usr/lib/$f.so.41
	ln -sf $f.so.41.1 $ROOTFS_DIR/usr/lib/$f.so
	$STRIP $ROOTFS_DIR/usr/lib/$f.so.41.1
    done

    popd
    touch "$STATE_DIR/icu4c.installed"
}

build_icu4c
