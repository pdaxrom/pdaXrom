#!/bin/sh

case $1 in
	hibernate|suspend)
		chvt 1
		;;
	thaw|resume)
		chvt 2
		;;
	*)
		exit 1
		;;
esac

exit 0

