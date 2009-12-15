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

PEKWM_THEMES_VERSION=1.0.5
PEKWM_THEMES=pekwm-themes-${PEKWM_THEMES_VERSION}.tar.gz
PEKWM_THEMES_MIRROR=http://aur.archlinux.org/packages/pekwm-themes/pekwm-themes
PEKWM_THEMES_DIR=$BUILD_DIR/pekwm-themes
PEKWM_THEMES_ENV="$CROSS_ENV_AC"

build_pekwm_themes() {
    test -e "$STATE_DIR/pekwm_themes.installed" && return
    banner "Build pekwm-themes"
    download $PEKWM_THEMES_MIRROR $PEKWM_THEMES
    extract $PEKWM_THEMES
    apply_patches $PEKWM_THEMES_DIR $PEKWM_THEMES
    pushd $TOP_DIR
    cd $PEKWM_THEMES_DIR

    local t=
    for f in $INSTALL_PEKWM_THEMES; do
	test -d $f  || continue
	echo "Installing theme $f"
	tar c $f | tar x -C ${ROOTFS_DIR}/usr/share/pekwm/themes || error
	t="$t $f"
    done

    if [ ! "x$t" = "x" ]; then
	rm -rf ${ROOTFS_DIR}/usr/share/pekwm/themes/default
	ln -sf $(echo $t | awk '{print $1}') ${ROOTFS_DIR}/usr/share/pekwm/themes/default
    fi

    popd
    touch "$STATE_DIR/pekwm_themes.installed"
}

build_pekwm_themes
