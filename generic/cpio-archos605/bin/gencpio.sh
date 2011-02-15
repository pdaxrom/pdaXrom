#!/bin/sh

ACTUAL_PWD=$(pwd)
SCRIPT_PATH=$(echo $ACTUAL_PWD/$(dirname $0|sed -r "s|^$ACTUAL_PWD||g") | sed -r "s|//|/|g" | sed -r "s|/./|/|g")
SCRIPT_NAME=$(basename $0|sed -r "s|\.sh$||g")

if [ "x$SCRIPT_NAME" = "xgencpio" ]; then
   echo "You must use a link to that script !"
   exit
fi

CPIO_DIR=$(echo $SCRIPT_PATH/$SCRIPT_NAME|sed -r "s|/$||g")

CPIO_START_LIST_FILE=${CPIO_DIR}-initial.list
CPIO_LIST_FILE=${CPIO_DIR}.list

>$CPIO_LIST_FILE

for f in $(find $CPIO_DIR |grep -v .svn)
   do
      NAME=$(echo $f|sed -r "s|$CPIO_DIR||g")

      if [ "x$NAME" = "x" ]; then
         continue
      fi

      RIGHTS=$(stat -c "%a" $f)

      if [ -L $f ]; then
         TARGET=$(stat -c "%N" $f|cut -f 3 -d '`'|sed -r "s/'//g")
         echo "slink $NAME $TARGET $RIGHTS 0 0" >>$CPIO_LIST_FILE
      elif [ -d $f ]; then
         echo "dir $NAME $RIGHTS 0 0" >>$CPIO_LIST_FILE
      elif [ -f $f ]; then
         echo "file $NAME $f $RIGHTS 0 0" >>$CPIO_LIST_FILE
      fi
   done

cat $CPIO_START_LIST_FILE >>$CPIO_LIST_FILE
