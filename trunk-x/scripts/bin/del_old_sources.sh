#!/bin/sh

show_error() {
    echo $*
    exit 1
}

BUILDER_HOME=""
SOURCE_URL=""

if [ -e ~/Choices/pdaXrom.cfg ]; then
    . ~/Choices/pdaXrom.cfg
else
    show_error "Cannot load pdaXrom service settings."
    exit 1
fi

test "$BUILDER_HOME" = "" && show_error "Please configure pdaXrom-builder directory in settings."
test "$SOURCE_URL" = "" && show_error "Please configure pdaXrom-builder sources url in settings."

echo "Update source list"

wget "$SOURCE_URL"/src/.lock -O /dev/null && show_error "Server updates source list. Please try again some later!"
wget "$SOURCE_URL"/src/Filelist -O /tmp/Filelist || show_error "Cannot load filelist from server"

touch "$BUILDER_HOME"/src/.lock
pushd $PWD

cd "$BUILDER_HOME"/src

for file in *.*; do
    F=`grep "$file" /tmp/Filelist`
    if [ "$F" = "" ]; then
	echo "Remove old file $file"
	rm -f $file
    fi
done

popd
rm -f "$BUILDER_HOME"/src/.lock
rm -f /tmp/Filelist
