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

SN_MONITOR_VERSION=svn
SN_MONITOR=sn-monitor-${SN_MONITOR_VERSION}
SN_MONITOR_SVN=https://pdaxrom.svn.sourceforge.net/svnroot/pdaxrom/trunk/sn-monitor
SN_MONITOR_DIR=$BUILD_DIR/sn-monitor-${SN_MONITOR_VERSION}
SN_MONITOR_ENV="$CROSS_ENV_AC"

build_sn_monitor() {
    test -e "$STATE_DIR/sn_monitor.installed" && return
    banner "Build sn-monitor"
    if [ ! -d $SN_MONITOR_DIR ]; then
	download_svn $SN_MONITOR_SVN $SN_MONITOR
	cp -R $SRC_DIR/$SN_MONITOR $SN_MONITOR_DIR
	apply_patches $SN_MONITOR_DIR $SN_MONITOR
    fi
    pushd $TOP_DIR
    cd $SN_MONITOR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SN_MONITOR_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/sn_monitor.installed"
}

build_sn_monitor
