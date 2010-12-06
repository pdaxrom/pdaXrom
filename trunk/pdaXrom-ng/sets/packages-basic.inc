. ./rules/core.sh

. $RULES_DIR/host_pkgconfig.sh
. $RULES_DIR/host_findutils.sh
. $RULES_DIR/host_genext2fs.sh
. $RULES_DIR/host_makebootfat.sh
. $RULES_DIR/host_cdrkit.sh
. $RULES_DIR/host_module-init-tools.sh
. $RULES_DIR/host_u-boot-mkimage.sh

. $RULES_DIR/create_root.sh

. $RULES_DIR/linux_kernel.sh

. $RULES_DIR/busybox.sh
. $RULES_DIR/host_ncurses.sh
. $RULES_DIR/ncurses.sh
. $RULES_DIR/module-init-tools.sh
. $SETS_DIR/packages-udev.inc
. $RULES_DIR/wireless_tools.sh
. $RULES_DIR/dhcpcd.sh
. $RULES_DIR/install_libc.sh
. $RULES_DIR/zlib.sh
. $RULES_DIR/ppp.sh
. $RULES_DIR/dropbear.sh
. $RULES_DIR/figlet.sh

if [ "$USE_SPLASH" = "yes" ]; then
    . $SETS_DIR/packages-dancesplash-fb.inc
fi

if [ "`get_kernel_subarch $TARGET_ARCH`" = "i386" ]; then
    . $RULES_DIR/ipw2100-fw.sh
    . $RULES_DIR/ipw2200-fw.sh
    . $RULES_DIR/iwlwifi-3945-ucode.sh
    . $RULES_DIR/iwlwifi-4965-ucode.sh
    . $RULES_DIR/iwlwifi-5000-ucode.sh
#    . $RULES_DIR/broadcom-sta.sh
fi

. $RULES_DIR/ralink-firmware.sh
