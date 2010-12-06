#!/bin/bash

TOP_DIR="$PWD"

SRC_DIR=`dirname "$0"`
SRC_DIR=`readlink -m "$SRC_DIR"`

DST_DIR=$1

if [ "x$DST_DIR" = "x" ]; then
    echo "$0 <new working directory>"
    exit 1
fi

echo "$SRC_DIR -> $DST_DIR"

mkdir -p $DST_DIR || exit 1

for f in $SRC_DIR/*; do
    t=`basename $f`
    echo "$f -> $DST_DIR/$t"
    ln -sf "$f" "$DST_DIR/$t" || exit 1
done

