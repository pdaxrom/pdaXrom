#!/bin/sh

export PATH=/usr/sbin:/usr/bin:/sbin:/bin:$PATH

# Do not run when pcmcia-cs is installed
#test -x /sbin/cardctl && exit 0

# We get two "add" events for hostap cards due to wifi0
echo "$INTERFACE" | grep -q wifi && exit 0

#
# Code taken from pcmcia-cs:/etc/pcmcia/network
#

# if this interface has an entry in /etc/network/interfaces, let ifupdown
# handle it
#if grep -q "iface \+$INTERFACE" /etc/network/interfaces; then
  case $ACTION in
    add)
    	start-stop-daemon -S -b -x ifup -- $INTERFACE
    	;;
    remove)
    	start-stop-daemon -S -b -x ifdown -- $INTERFACE
    	;;
  esac
  
  exit 0
#fi

