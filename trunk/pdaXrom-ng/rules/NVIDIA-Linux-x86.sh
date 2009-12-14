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

NVIDIA_LINUX_X86_VERSION=180.44
NVIDIA_LINUX_X86=NVIDIA-Linux-x86-${NVIDIA_LINUX_X86_VERSION}-pkg1.run
NVIDIA_LINUX_X86_MIRROR=http://us.download.nvidia.com/XFree86/Linux-x86/180.44
NVIDIA_LINUX_X86_DIR=$BUILD_DIR/NVIDIA-Linux-x86-${NVIDIA_LINUX_X86_VERSION}-pkg1
NVIDIA_LINUX_X86_ENV="$CROSS_ENV_AC"

build_NVIDIA_Linux_x86() {
    test -e "$STATE_DIR/NVIDIA_Linux_x86.installed" && return
    banner "Build NVIDIA-Linux-x86"
    download $NVIDIA_LINUX_X86_MIRROR $NVIDIA_LINUX_X86
    pushd $TOP_DIR
    cd $BUILD_DIR
    sh ${SRC_DIR}/${NVIDIA_LINUX_X86} -x
    apply_patches $NVIDIA_LINUX_X86_DIR/usr/src/nv $NVIDIA_LINUX_X86
    cd $NVIDIA_LINUX_X86_DIR/usr/src/nv

    local SUBARCH=`get_kernel_subarch $TARGET_ARCH`

    make \
	SYSSRC=$KERNEL_DIR \
	SUBARCH=$SUBARCH \
	KERNEL_MODLIB=${ROOTFS_DIR}/lib/modules/`ls ${ROOTFS_DIR}/lib/modules` \
	CC=${TOOLCHAIN_PREFIX}/bin/${CROSS}gcc \
	CROSS_COMPILE=${TOOLCHAIN_PREFIX}/bin/${CROSS} module || error "build"

    local MODULE_ROOT="${ROOTFS_DIR}/lib/modules/`ls ${ROOTFS_DIR}/lib/modules`/kernel/drivers"

    mkdir -p ${MODULE_ROOT}/video
    $INSTALL -m 0664 nvidia.ko ${MODULE_ROOT}/video

    local K_V=`ls $ROOTFS_DIR/lib/modules`
    $DEPMOD -a -b $ROOTFS_DIR $K_V


    cd $NVIDIA_LINUX_X86_DIR
    rm -rf fakeroot
    mkdir -p fakeroot/usr/bin
    mkdir -p fakeroot/usr/lib/xorg
    mkdir -p fakeroot/usr/share

    $INSTALL -m 755 -t fakeroot/usr/bin \
	usr/bin/nvidia-settings \
	usr/bin/nvidia-smi \
	usr/bin/nvidia-xconfig

    cp -a usr/include fakeroot/usr
    cp -a usr/lib fakeroot/usr
    cp -a usr/X11R6/lib/* fakeroot/usr/lib
    cp -a usr/share/applications fakeroot/usr/share
    cp -a usr/share/pixmaps fakeroot/usr/share

    mv fakeroot/usr/lib/modules fakeroot/usr/lib/xorg

    sed -i -e "s|__UTILS_PATH__|/usr/bin|; s|__PIXMAP_PATH__|/usr/share/pixmaps|" fakeroot/usr/share/applications/nvidia-settings.desktop
    sed -i -e "s|__LIBGL_PATH__|/usr/lib|" fakeroot/usr/lib/libGL.la

    for f in libcuda.so libGL.so libnvidia-tls.so libvdpau.so libGLcore.so \
	    libnvidia-cfg.so libvdpau_nvidia.so libvdpau_trace.so tls/libnvidia-tls.so \
	    libXvMCNVIDIA.so \
	    xorg/modules/libnvidia-wfb.so \
	    xorg/modules/extensions/libglx.so; do
	ln -sf ${f/*\/}.${NVIDIA_LINUX_X86_VERSION} fakeroot/usr/lib/${f}.1
	ln -sf ${f/*\/}.${NVIDIA_LINUX_X86_VERSION} fakeroot/usr/lib/${f}
    done

    install_fakeroot_finish || error

    cp -a fakeroot/usr/include/* $TARGET_INC

    popd
    touch "$STATE_DIR/NVIDIA_Linux_x86.installed"
}

build_NVIDIA_Linux_x86
