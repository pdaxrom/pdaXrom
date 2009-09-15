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

ALSA_UTILS=alsa-utils-1.0.19.tar.bz2
ALSA_UTILS_MIRROR=ftp://ftp.alsa-project.org/pub/utils
ALSA_UTILS_DIR=$BUILD_DIR/alsa-utils-1.0.19
ALSA_UTILS_ENV=

build_alsa_utils() {
    test -e "$STATE_DIR/alsa_utils-1.0.18" && return
    banner "Build $ALSA_UTILS"
    download $ALSA_UTILS_MIRROR $ALSA_UTILS
    extract $ALSA_UTILS
    apply_patches $ALSA_UTILS_DIR $ALSA_UTILS
    pushd $TOP_DIR
    cd $ALSA_UTILS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ALSA_UTILS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-nls \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -m 755 alsactl/alsactl $ROOTFS_DIR/usr/sbin/
    $STRIP $ROOTFS_DIR/usr/sbin/alsactl
    
    for f in alsamixer/alsamixer amidi/amidi amixer/amixer aplay/aplay \
	    iecset/iecset seq/aconnect/aconnect seq/aplaymidi/aplaymidi \
	    seq/aplaymidi/arecordmidi seq/aseqdump/aseqdump seq/aseqnet/aseqnet; do
	$STRIP $f
	$INSTALL -m 755 $f $ROOTFS_DIR/usr/bin/
    done
    ln -sf aplay $ROOTFS_DIR/usr/bin/arecord

    for f in 00main default help info test hda; do
	$INSTALL -D -m 644 alsactl/init/$f $ROOTFS_DIR/usr/share/alsa/init/$f
    done

    mkdir -p $ROOTFS_DIR/var/lib/alsa

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/alsa-utils $ROOTFS_DIR/etc/init.d/alsa-utils
    if [ "$USE_FASTBOOT" = "yes" ]; then
	install_rc_start alsa-utils 00
    else
	install_rc_start alsa-utils 90
    fi
    install_rc_stop  alsa-utils 10

    popd
    touch "$STATE_DIR/alsa_utils-1.0.18"
}

build_alsa_utils
