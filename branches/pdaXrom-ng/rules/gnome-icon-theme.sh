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

GNOME_ICON_THEME=gnome-icon-theme-2.24.0.tar.bz2
GNOME_ICON_THEME_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/gnome-icon-theme/2.24
GNOME_ICON_THEME_DIR=$BUILD_DIR/gnome-icon-theme-2.24.0
GNOME_ICON_THEME_ENV="$CROSS_ENV_AC"

build_gnome_icon_theme() {
    test -e "$STATE_DIR/gnome_icon_theme.installed" && return
    banner "Build gnome-icon-theme"
    download $GNOME_ICON_THEME_MIRROR $GNOME_ICON_THEME
    extract $GNOME_ICON_THEME
    apply_patches $GNOME_ICON_THEME_DIR $GNOME_ICON_THEME
    pushd $TOP_DIR
    cd $GNOME_ICON_THEME_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GNOME_ICON_THEME_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB
    ) || error "configure"
    
    make $MAKEARGS || error

    make $MAKEARGS DESTDIR=$ROOTFS_DIR install || error

    ln -sf gnome $ROOTFS_DIR/usr/share/icons/hicolor
    ln -sf gnome $ROOTFS_DIR/usr/share/icons/default

    mkdir -p $ROOTFS_DIR/etc/gtk-2.0
    echo "gtk-icon-theme-name=\"gnome\"" >> $ROOTFS_DIR/etc/gtk-2.0/gtkrc

    popd
    touch "$STATE_DIR/gnome_icon_theme.installed"
}

build_gnome_icon_theme
