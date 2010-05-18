#!/bin/sh
#
# pdaXrom-ng wpa supplicant start/stop script
# Copyright (C) 2010 Alexander Chukov <sash@pdaXrom.org>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# On Debian GNU/Linux systems, the text of the GPL license,
# version 2, can be found in /usr/share/common-licenses/GPL-2.


CFG_DIR="/var/lib/wpa_supplicant_conf"
DAEMON=/usr/sbin/wpa_supplicant

if [ ! -x "$DAEMON" ]; then
    exit 0
fi

if [ "$IFACE" = "lo" ]; then
    exit 0
fi

mkdir -p "$CFG_DIR"

CFG_NAME="${IFACE}.conf"
CFG_PID="/var/run/wpa_supplicant-${IFACE}.pid"
CFG_FILE="${CFG_DIR}/${CFG_NAME}"
CFG_FILE_TMP="${CFG_DIR}/${CFG_NAME}.tmp"

case "$MODE" in
start)
    if [ ! "x$IF_WPA_SSID" = "x" ]; then
	echo " ssid=$IF_WPA_SSID" >> "$CFG_FILE_TMP"
    fi
    if [ ! "x$IF_WPA_PSK" = "x" ]; then
	echo " psk=$IF_WPA_PSK" >> "$CFG_FILE_TMP"
    fi
    if [ ! "x$IF_WPA_PROTO" = "x" ]; then
	echo " proto=$IF_WPA_PROTO" >> "$CFG_FILE_TMP"
    fi
    if [ ! "x$IF_WPA_PAIRWISE" = "x" ]; then
	echo " pairwise=$IF_WPA_PAIRWISE" >> "$CFG_FILE_TMP"
    fi
    if [ ! "x$IF_WPA_GROUP" = "x" ]; then
	echo " group=$IF_WPA_GROUP" >> "$CFG_FILE_TMP"
    fi
    if [ ! "x$IF_WPA_KEY_MGMT" = "x" ]; then
	echo " key_mgmt=$IF_WPA_KEY_MGMT" >> "$CFG_FILE_TMP"
    fi
    if [ ! "x$IF_WPA_AP_SCAN" = "x" ]; then
	echo " ap_scan=$IF_WPA_AP_SCAN" >> "$CFG_FILE_TMP"
    fi
    if [ ! "x$IF_WPA_DRIVER" = "x" ]; then
	echo " driver=$IF_WPA_DRIVER" >> "$CFG_FILE_TMP"
    fi
    if [ -e "$CFG_FILE_TMP" ]; then
	echo "network={"	>  "$CFG_FILE"
	cat "$CFG_FILE_TMP"	>> "$CFG_FILE"
	echo "}"		>> "$CFG_FILE"
	rm -f "$CFG_FILE_TMP"
	start-stop-daemon -S -q -b -m -p "$CFG_PID" -x "$DAEMON" -- -i"${IFACE}" -c"${CFG_FILE}"
    fi
    ;;
stop)
    if [ -e "$CFG_FILE" ]; then
	start-stop-daemon -K -q -p "$CFG_PID" -x "$DAEMON"
	rm -f "$CFG_FILE"
	rm -f "$CFG_PID"
    fi
    ;;
esac

exit 0
