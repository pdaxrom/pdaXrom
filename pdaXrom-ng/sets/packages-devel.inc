. $RULES_DIR/target-binutils.sh
. $RULES_DIR/target-gmp.sh
. $RULES_DIR/target-mpfr.sh
. $RULES_DIR/target-gcc.sh
case $TARGET_ARCH in
*-ps3-*)
    . $RULES_DIR/target-spu.sh
    ;;
esac
. $RULES_DIR/target-make.sh
. $RULES_DIR/target-gawk.sh
. $RULES_DIR/target-sed.sh
. $RULES_DIR/target-bash.sh
. $RULES_DIR/target-groff.sh
. $RULES_DIR/target-patch.sh
. $RULES_DIR/target-distcc.sh
. $RULES_DIR/target-pkgconfig.sh
. $RULES_DIR/target-imake.sh
. $RULES_DIR/target-xorg-cf-files.sh
. $RULES_DIR/target-gccmakedep.sh
. $RULES_DIR/target-lndir.sh
. $RULES_DIR/target-makedepend.sh
. $RULES_DIR/host_file.sh
. $RULES_DIR/file.sh

. $RULES_DIR/gdb.sh
. $RULES_DIR/target-dev-tweaks.sh
