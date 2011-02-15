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

WPA_SUPPLICANT_VERSION=0.6.9
WPA_SUPPLICANT=wpa_supplicant-${WPA_SUPPLICANT_VERSION}.tar.gz
WPA_SUPPLICANT_MIRROR=http://hostap.epitest.fi/releases
WPA_SUPPLICANT_DIR=$BUILD_DIR/wpa_supplicant-${WPA_SUPPLICANT_VERSION}
WPA_SUPPLICANT_ENV="$CROSS_ENV_AC"

build_wpa_supplicant() {
    test -e "$STATE_DIR/wpa_supplicant.installed" && return
    banner "Build wpa_supplicant"
    download $WPA_SUPPLICANT_MIRROR $WPA_SUPPLICANT
    extract $WPA_SUPPLICANT
    apply_patches $WPA_SUPPLICANT_DIR $WPA_SUPPLICANT
    pushd $TOP_DIR
    cd $WPA_SUPPLICANT_DIR

    cp wpa_supplicant/defconfig wpa_supplicant/.config
    echo "CC=${CROSS}gcc"	>> wpa_supplicant/.config
    echo "CFLAGS+=-O2"		>> wpa_supplicant/.config
    echo "LIBS+=-L${TARGET_LIB}">> wpa_supplicant/.config
    echo "LIBS+=-Wl,-rpath,${TARGET_LIB}">> wpa_supplicant/.config
    echo "LIBS+=-lssl"		>> wpa_supplicant/.config
    echo "CONFIG_DRIVER_WEXT=y" >> wpa_supplicant/.config

    make -C wpa_supplicant CC="${CROSS}gcc -L${TARGET_LIB} -Wl,-rpath,${TARGET_LIB}" LIBDIR=/usr/lib BINDIR=/usr/sbin || error

    for f in wpa_cli wpa_passphrase wpa_supplicant; do
	$INSTALL -D -m 755 wpa_supplicant/$f $ROOTFS_DIR/usr/sbin/$f || error
	$STRIP $ROOTFS_DIR/usr/sbin/$f || error
    done

    $INSTALL -D -m 755 ${GENERICFS_DIR}/etc/wpa_supplicant/ifupdown.sh ${ROOTFS_DIR}/etc/wpa_supplicant/ifupdown.sh || error "install script"
    ln -sf ../../wpa_supplicant/ifupdown.sh ${ROOTFS_DIR}/etc/network/if-post-down.d/wpasupplicant
    ln -sf ../../wpa_supplicant/ifupdown.sh ${ROOTFS_DIR}/etc/network/if-pre-up.d/wpasupplicant

    popd
    touch "$STATE_DIR/wpa_supplicant.installed"
}

build_wpa_supplicant
