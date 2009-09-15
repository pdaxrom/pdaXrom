. $RULES_DIR/libjpeg.sh
. $RULES_DIR/libpng.sh
. $RULES_DIR/freetype.sh
. $RULES_DIR/dancesplash-fb.sh

echo "c 29 0" > $ROOTFS_DIR/dev/.squashfs_dev_node.fb0
echo "c 4 0" > $ROOTFS_DIR/dev/.squashfs_dev_node.tty0
echo "c 4 1" > $ROOTFS_DIR/dev/.squashfs_dev_node.tty1
echo "c 4 2" > $ROOTFS_DIR/dev/.squashfs_dev_node.tty2
echo "c 4 3" > $ROOTFS_DIR/dev/.squashfs_dev_node.tty3

