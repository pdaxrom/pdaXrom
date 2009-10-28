#!/bin/bash

pushdir() {
    pushd $1 > /dev/null
}

popdir() {
    popd > /dev/null
}

allconfigs() {
    pushdir $PWD
    echo "Next configurations are available for build:"
    echo
    cd platforms
    for d in *; do
	cd $d
	for f in *; do
	    echo "$d/$f"
	done
	cd ..
	echo
    done
    echo
    echo "To build selected configuration use"
    echo "./build.sh <configuration> <build args> ..."
    echo "or"
    echo "./platform/<configuration> <build args> ..."
    popdir
}

configs() {
    pushdir $PWD
    echo "Next configurations matches keyword $1:"
    echo
    cd platforms
    for d in *; do
	cd $d
	for f in *; do
	    echo "$d/$f" | grep "$1"
	done
	cd ..
	echo
    done
    echo
    echo "To build selected configuration use"
    echo "./build.sh <configuration> <build args> ..."
    echo "or"
    echo "./platform/<configuration> <build args> ..."
    popdir
}

if [ "$1" = "" ]; then
    allconfigs
    exit 0
fi

if [ ! -f "platforms/$1" -a ! -f $1 ]; then
    configs "$1"
    exit 0
fi

c=$1

shift

echo "Selecated config $c"

TOP_DIR="$PWD"

if [ -f "platforms/$c" ]; then
    SETS_DIR="$TOP_DIR/sets" bash "platforms/$c" $@
else
    SETS_DIR="$TOP_DIR/sets" bash "$c" $@
fi
