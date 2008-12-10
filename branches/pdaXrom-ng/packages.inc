. ./rules/core.sh

. $RULES_DIR/host_pkgconfig.sh
. $RULES_DIR/host_genext2fs.sh
. $RULES_DIR/host_cdrkit.sh
. $RULES_DIR/host_module-init-tools.sh
. $RULES_DIR/create_root.sh
. $RULES_DIR/linux_kernel.sh
. $RULES_DIR/busybox.sh
. $RULES_DIR/host_ncurses.sh
. $RULES_DIR/ncurses.sh
. $RULES_DIR/module-init-tools.sh
. $RULES_DIR/udev.sh
. $RULES_DIR/wireless_tools.sh
. $RULES_DIR/install_glibc.sh
. $RULES_DIR/zlib.sh
. $RULES_DIR/dropbear.sh
. $RULES_DIR/libjpeg.sh
. $RULES_DIR/libpng.sh

. $RULES_DIR/alsa-lib.sh
. $RULES_DIR/alsa-utils.sh
. $RULES_DIR/SDL.sh
. $RULES_DIR/SDL_image.sh

. $RULES_DIR/pyldin601.sh

. $RULES_DIR/create_initramfs.sh
