#!/bin/bash

TOP_DIR="$PWD"

SRC_DIR=`dirname "${TOP_DIR}/$0"`
DST_DIR=$1

if [ "x$DST_DIR" = "x" ]; then
    echo "$0 <build dir path>"
    exit 1
fi

mkdir -p $DST_DIR || exit 1

echo "$SRC_DIR -> $DST_DIR"

for f in $SRC_DIR/*; do
    t=`basename $f`
    echo "$f -> $DST_DIR/$t"
    ln -sf "$f" "$DST_DIR/$t" || exit 1
done

