#!/bin/sh

HD_DEVICE=$1
ROOT=$2
ROOT_PATH=$3
MEDIA=$4
MEDIA_PATH=$5
MEDIA_VOLUME_LABEL=$6
AOS_FULLFILENAME=$7

HDD_LOCK_FORMAT_SCRIPT="/etc/scripts/set_hdd.sh"
HDD_LOCK_UPDATE_SCRIPT="/etc/scripts/hdd_lock_update.sh"

AUI=/bin/aui

MAIN_TITLE="HDD_Recovery_2"

KEY=`$AUI -c select -T $MAIN_TITLE -a centered -t " " \
	-t "usb" -t "format disk" --blocked`

SELECT=`$AUI --get-selected`

if [ $SELECT = "selected=0" ] || [ $KEY = "key=esc" ] ; then
	echo "continue"
	$HDD_LOCK_FORMAT_SCRIPT $HD_DEVICE $ROOT $MEDIA $MEDIA_VOLUME_LABEL $ROOT_PATH $MEDIA_PATH 0 $MAIN_TITLE
	$HDD_LOCK_UPDATE_SCRIPT $HD_DEVICE $MEDIA $MEDIA_PATH $AOS_FULLFILENAME $ROOT $ROOT_PATH

elif [ $SELECT = "selected=1" ] ; then
	# new disk
	echo "formating disk ..."
	$HDD_LOCK_FORMAT_SCRIPT $HD_DEVICE $ROOT $MEDIA $MEDIA_VOLUME_LABEL $ROOT_PATH $MEDIA_PATH 1 $MAIN_TITLE
	$HDD_LOCK_UPDATE_SCRIPT $HD_DEVICE $MEDIA $MEDIA_PATH $AOS_FULLFILENAME $ROOT $ROOT_PATH
fi

exit
