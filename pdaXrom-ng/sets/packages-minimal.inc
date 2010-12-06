. ./rules/core.sh

. $RULES_DIR/host_pkgconfig.sh
. $RULES_DIR/host_findutils.sh
. $RULES_DIR/host_genext2fs.sh
. $RULES_DIR/host_makebootfat.sh
. $RULES_DIR/host_module-init-tools.sh
. $RULES_DIR/host_u-boot-mkimage.sh

. $RULES_DIR/create_root.sh

. $RULES_DIR/linux_kernel.sh

. $RULES_DIR/busybox.sh
. $RULES_DIR/host_ncurses.sh
. $RULES_DIR/ncurses.sh
. $RULES_DIR/module-init-tools.sh
. $SETS_DIR/packages-udev.inc
. $RULES_DIR/install_libc.sh
. $RULES_DIR/zlib.sh
. $RULES_DIR/figlet.sh
