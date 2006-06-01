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

wget "$SOURCE_URL"/src/.lock -O /dev/null 2>/dev/null >/dev/null && show_error "Server updates source list. Please try again some later!"
wget "$SOURCE_URL"/src/Filelist -O /tmp/Filelist || show_error "Cannot load filelist from server"

touch "$BUILDER_HOME"/src/.lock
pushd $PWD

cd "$BUILDER_HOME"/src
cat /tmp/Filelist | while read LINE ;
do
    SFILE=`echo $LINE | cut -f1 -d' '`
    SMD5=`echo $LINE | cut -f2 -d' '`
    if [ -e "$SFILE" ]; then
	MD5=`md5sum "$SFILE" | cut -f1 -d' '`
	if [ "$SMD5" = "$MD5" ]; then
	    echo "Skip file $SFILE - need not to update"
	else
	    rm -f "$SFILE"
	    wget "$SOURCE_URL"/src/"$SFILE"
	fi
    else
	wget "$SOURCE_URL"/src/"$SFILE"
    fi
done

popd
rm -f "$BUILDER_HOME"/src/.lock
rm -f /tmp/Filelist
