#!/bin/sh

if [ $# -lt 1 ]; then
    echo "$0 <glibc-gconv-dir>"
    exit 1
fi

GCONVDIR=$1

IPKTMP=/tmp/ipk$$

if [ "x$ARCH" = "x" ]; then
    ARCH="noarch"
fi

if [ "x$VERSION" = "x" ]; then
    VERSION="1.0.0"
fi

if [ "x$STRIP" = "x" ]; then
    STRIP="strip"
fi

if [ "x$FEEDDIR" = "x" ]; then
    FEEDDIR=$PWD
fi

if [ "x$MKIPKG" = "x" ]; then
    MKIPKG="mkipkg"
fi

pushd $GCONVDIR

for file in *.so; do
    ENC=`echo $file | sed -e 's/\.so//g' | tr [:upper:] [:lower:] | tr '_' '-' | tr '.' '-'`
    echo $ENC

    mkdir -p $IPKTMP/CONTROL
    mkdir -p $IPKTMP/usr/lib/gconv
    cp -a $file $IPKTMP/usr/lib/gconv/

    $STRIP $IPKTMP/usr/lib/gconv/$file

    echo "Package: glibc-gconv-$ENC"		 > $IPKTMP/CONTROL/control
    echo "Priority: optional"			>> $IPKTMP/CONTROL/control
    echo "Version: $VERSION"			>> $IPKTMP/CONTROL/control
    echo "Architecture: $ARCH"			>> $IPKTMP/CONTROL/control
    echo "Maintainer: pdaXrom team <team@pdaXrom.org>" >> $IPKTMP/CONTROL/control
    echo "License: GPL"				>> $IPKTMP/CONTROL/control
    echo "Depends: glibc"			>> $IPKTMP/CONTROL/control
    echo "Description: iconv module $ENC" 	>> $IPKTMP/CONTROL/control

    $MKIPKG $IPKTMP $FEEDDIR

    rm -rf $IPKTMP
done

echo $IPKTMP

popd
