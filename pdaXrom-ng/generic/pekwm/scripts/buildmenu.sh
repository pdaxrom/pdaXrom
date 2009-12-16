#!/bin/sh
#
# (c) pdaXrom team, 2006
# http://www.pdaXrom.org
#

APPMENU_DIR=${HOME}/.pekwm

convert_desktop_file() {
awk '
BEGIN { 
    FS="=";
    sn="";
    name="";
    gname="";
    image="";
}
/^GenericName/ && !/\[/ {gname = $2}
/^Name/ && !/\[/ {name = $2}
/^Icon/ {image = $2}
/^Exec/ {sub("%[fFuU]",""); exe = $2}
/^StartupNotify/ {if ( $2 == "True" || $2 == "true") sn = "yes"}
END {
    if (exe != "")
	print "Entry = \"" name "\" { Actions = \"Exec " exe "\" }"
}' $1
}

test -d $APPMENU_DIR || mkdir $APPMENU_DIR

APPINCS="
	${APPMENU_DIR}/AudioVideo.inc
	${APPMENU_DIR}/Network.inc
	${APPMENU_DIR}/Office.inc
	${APPMENU_DIR}/Graphics.inc
	${APPMENU_DIR}/Games.inc
	${APPMENU_DIR}/Settings.inc
	${APPMENU_DIR}/Utils.inc
	${APPMENU_DIR}/Applications.inc
"

for f in $APPINCS; do
    rm -f "$f"
    touch "$f"
done

SETTINGS=
AV=
NETWORK=
OFFICE=
GRAPHICS=
GAMES=
UTILS=
APPS=

for file in /usr/share/applications/* /usr/local/share/applications/*; do
    if [ -f $file ]; then
	TYPE=`awk -F'=' '/^Categories/ {print $2}' $file`
	case $TYPE in 
	    *Utility*|*System*)
		    UTILS="${UTILS}`convert_desktop_file $file`
"
		;;
	    *Settings*)
		    SETTINGS="${SETTINGS}`convert_desktop_file $file`
"
		;;
	    *AudioVideo*)
		    AV="${AV}`convert_desktop_file $file`
"
		;;
	    *Network*|*Email*)
		    NETWORK="${NETWORK}`convert_desktop_file $file`
"
		;;
	    *Office*|*WordProcessor*|*TextEditor*)
		    OFFICE="${OFFICE}`convert_desktop_file $file`
"
		;;
	    *Graphics*)
		    GRAPHICS="${GRAPHICS}`convert_desktop_file $file`
"
		;;
	    *Game*)
		    GAMES="${GAMES}`convert_desktop_file $file`
"
		;;
	    *)
		    APPS="${APPS}`convert_desktop_file $file`
"
		;;
	esac
    fi
done

echo "$SETTINGS" | sort -o ${APPMENU_DIR}/Settings.inc
echo "$AV" | sort -o ${APPMENU_DIR}/AudioVideo.inc
echo "$NETWORK" | sort -o ${APPMENU_DIR}/Network.inc
echo "$OFFICE" | sort -o ${APPMENU_DIR}/Office.inc
echo "$GRAPHICS" | sort -o ${APPMENU_DIR}/Graphics.inc
echo "$GAMES" | sort -o ${APPMENU_DIR}/Games.inc
echo "$UTILS" | sort -o ${APPMENU_DIR}/Utils.inc
echo "$APPS" | sort -o ${APPMENU_DIR}/Applications.inc

cat > ${APPMENU_DIR}/appmenu << EOF
Submenu = "Accessories" {
INCLUDE = "${APPMENU_DIR}/Utils.inc"
}
Submenu = "Audio and Video" {
INCLUDE = "${APPMENU_DIR}/AudioVideo.inc"
}
Submenu = "Games" {
INCLUDE = "${APPMENU_DIR}/Games.inc"
}
Submenu = "Graphics" {
INCLUDE = "${APPMENU_DIR}/Graphics.inc"
}
Submenu = "Network" {
INCLUDE = "${APPMENU_DIR}/Network.inc"
}
Submenu = "Office" {
INCLUDE = "${APPMENU_DIR}/Office.inc"
}
Submenu = "Settings" {
INCLUDE = "${APPMENU_DIR}/Settings.inc"
}
Submenu = "Other" {
INCLUDE = "${APPMENU_DIR}/Applications.inc"
}
EOF
