HOST_MODULE_INIT_TOOLS=module-init-tools-3.5.tar.bz2
HOST_MODULE_INIT_TOOLS_MIRROR=http://www.kernel.org/pub/linux/utils/kernel/module-init-tools
HOST_MODULE_INIT_TOOLS_DIR=$HOST_BUILD_DIR/module-init-tools-3.5

build_host_module_init_tools() {
    test -e "$STATE_DIR/host_module_init_tools" && return
    banner "Build $HOST_MODULE_INIT_TOOLS"
    download $HOST_MODULE_INIT_TOOLS_MIRROR $HOST_MODULE_INIT_TOOLS
    extract_host $HOST_MODULE_INIT_TOOLS
    apply_patches $HOST_MODULE_INIT_TOOLS_DIR $HOST_MODULE_INIT_TOOLS
    pushd $TOP_DIR
    cd $HOST_MODULE_INIT_TOOLS_DIR
    ./configure --prefix=$HOST_BIN_DIR --target=$TARGET_ARCH || error
    make depmod || error
    cp -R depmod $HOST_BIN_DIR/bin/
    popd
    touch "$STATE_DIR/host_module_init_tools"
}

build_host_module_init_tools
