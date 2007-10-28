#!/bin/sh

APP=`cat $1/CONTROL/control | grep 'Package:' | cut -d':' -f2 | sed 's/\ //g'`

LIBS=`find $1 | xargs file | grep 'ELF 32-bit' | cut -d':' -f1 | xargs objdump -x | grep NEEDED | sort | uniq | sed 's/^.*\ //'`

OLDEPS=`cat $1/CONTROL/control | grep 'Depends:' | cut -d':' -f2 | tr ',' '\n'`

DEPS=`{ \
echo "$OLDEPS" | sed 's/\ //g' ; \
for file in $LIBS; do \
    grep -h "$file" $2/*.libs | cut -d':' -f1 ; \
done ; \
} | sort | uniq | awk -v lala=$APP '{ if ( $1 != lala ) { print $1 } }' | tr '\n' ',' | sed 's/,$//g' | sed 's/^,//g'`

sed -i "s/^Depends:.*/Depends: $DEPS/" $1/CONTROL/control

ls -R $1 | grep -h 'lib.*so' 2>/dev/null | xargs echo "$APP:" > $2/$APP.libs
