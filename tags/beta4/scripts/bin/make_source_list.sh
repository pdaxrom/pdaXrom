#!/bin/sh

show_error() {
    echo $*
    exit 1
}

BUILDER_HOME=""

if [ -e ~/Choices/pdaXrom.cfg ]; then
    . ~/Choices/pdaXrom.cfg
else
    show_error "Cannot load pdaXrom service settings."
    exit 1
fi

test -d "$BUILDER_HOME"/src || show_error "Please configure pdaXrom-builder directory in settings."

echo "Update source list"

rm -f "$BUILDER_HOME"/src/Filelist
touch "$BUILDER_HOME"/src/.lock
pushd $PWD 2>/dev/null >/dev/null
cd "$BUILDER_HOME"/src
for file in *.*; do
    MD5=`md5sum "$file" | cut -f1 -d' '`
    echo "$file $MD5"
    echo "$file $MD5" >> "$BUILDER_HOME"/src/Filelist
done
popd 2>/dev/null >/dev/null
rm -f "$BUILDER_HOME"/src/.lock
