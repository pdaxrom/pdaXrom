#!/bin/sh

if [ $# -lt 2 ]; then
    echo "$0 <pkgname> <rootdir>"
    exit 1
fi

PKGNAME=$1
ROOTDIR=$2

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

cd $ROOTDIR

for dir in `find . -name locale -type d` ; do
    pushd $ROOTDIR/$dir

    for file in *; do
	ENC=`echo $file | sed -e 's/\.so//g' | tr [:upper:] [:lower:] | tr '_' '-' | tr '.' '-' | tr '@' '-'`
	echo $ENC

	echo $dir -- $ENC

	mkdir -p $IPKTMP/CONTROL
	mkdir -p $IPKTMP/$dir
	cp -a $file $IPKTMP/$dir

	echo "Package: $PKGNAME-locale-$ENC"		 > $IPKTMP/CONTROL/control
	echo "Priority: optional"			>> $IPKTMP/CONTROL/control
	echo "Version: $VERSION"			>> $IPKTMP/CONTROL/control
	echo "Architecture: $ARCH"			>> $IPKTMP/CONTROL/control
	echo "Maintainer: pdaXrom team <team@pdaXrom.org>" >> $IPKTMP/CONTROL/control
	echo "License: "				>> $IPKTMP/CONTROL/control
	echo "Depends: $PKGNAME"			>> $IPKTMP/CONTROL/control
	echo "Description: locale $ENC" 		>> $IPKTMP/CONTROL/control

	$MKIPKG $IPKTMP $FEEDDIR

	rm -rf $IPKTMP
    done

    echo $IPKTMP

    popd

    rm -rf $ROOTDIR/$dir

done

cd $ROOTDIR

for dir in `find . -name man -type d` ; do
	echo $dir -- man files

	mkdir -p $IPKTMP/CONTROL
	mkdir -p $IPKTMP/$dir
	cp -a $dir/* $IPKTMP/$dir/

	echo "Package: $PKGNAME-man"			 > $IPKTMP/CONTROL/control
	echo "Priority: optional"			>> $IPKTMP/CONTROL/control
	echo "Version: $VERSION"			>> $IPKTMP/CONTROL/control
	echo "Architecture: $ARCH"			>> $IPKTMP/CONTROL/control
	echo "Maintainer: pdaXrom team <team@pdaXrom.org>" >> $IPKTMP/CONTROL/control
	echo "License: "				>> $IPKTMP/CONTROL/control
	echo "Depends: $PKGNAME"			>> $IPKTMP/CONTROL/control
	echo "Description: man files" 			>> $IPKTMP/CONTROL/control

	$MKIPKG $IPKTMP $FEEDDIR

	rm -rf $IPKTMP
    rm -rf $ROOTDIR/$dir
done
