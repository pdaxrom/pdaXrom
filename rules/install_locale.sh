target_locale_install() {
    test -f $TOOLCHAIN_SYSROOT/usr/bin/iconv  && install_rootfs_usr_bin $TOOLCHAIN_SYSROOT/usr/bin/iconv
    test -f $TOOLCHAIN_SYSROOT/usr/bin/locale && install_rootfs_usr_bin $TOOLCHAIN_SYSROOT/usr/bin/locale
    test -f $TOOLCHAIN_SYSROOT/usr/bin/localedef && install_rootfs_usr_bin $TOOLCHAIN_SYSROOT/usr/bin/localedef
    ln -sf ../../var/lib/locale $ROOTFS_DIR/usr/lib/locale
    mkdir -p $ROOTFS_DIR/var/lib/locale
    mkdir -p $ROOTFS_DIR/usr/share/i18n/charmaps
    mkdir -p $ROOTFS_DIR/usr/share/i18n/locales

    test -e $TOOLCHAIN_SYSROOT/usr/share/i18n/charmaps || return

    for f in UTF-8 $LIBC_CHARMAPS; do
	test -f $TOOLCHAIN_SYSROOT/usr/share/i18n/charmaps/$f.gz && $INSTALL -D -m 644 $TOOLCHAIN_SYSROOT/usr/share/i18n/charmaps/$f.gz $ROOTFS_DIR/usr/share/i18n/charmaps/$f.gz
    done

    for f in da_DK en_US en_GB ru_RU i18n iso14651_t1 iso14651_t1_common \
		translit_circle translit_compat translit_fraction translit_narrow \
		translit_small translit_cjk_compat translit_combining translit_font \
		translit_neutral  translit_wide POSIX $LIBC_LOCALES; do
	test -f $TOOLCHAIN_SYSROOT/usr/share/i18n/locales/$f && $INSTALL -D -m 644 $TOOLCHAIN_SYSROOT/usr/share/i18n/locales/$f $ROOTFS_DIR/usr/share/i18n/locales/$f
    done

    echo "LANG=\"${DEFAULT_LOCALE-en_US.UTF-8}\"" > $ROOTFS_DIR/etc/default/locale
    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/genlocale $ROOTFS_DIR/etc/init.d/genlocale
    $INSTALL -D -m 755 $GENERICFS_DIR/etc/profile.d/locale.sh $ROOTFS_DIR/etc/profile.d/locale.sh
    install_rc_start genlocale 11
}

target_locale_install
