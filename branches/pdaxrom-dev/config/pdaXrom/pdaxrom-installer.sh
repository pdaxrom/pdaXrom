#!/bin/bash

dialog --backtitle "pdaXrom Maintenance Menu" --msgbox "Welcome to pdaXrom" 7 30

dialog --backtitle "pdaXrom Maintenance Menu" --msgbox "Insert CF/SD Media then press OK" 7 40 

mount /mnt/cf
mount /mnt/card

until [ $end = "stop" ]
do

rm -f ans*

dialog --backtitle "pdaXrom Maintenance Menu" --nocancel --menu "Choose and option:" 11 35 4 \
	1 Install \
	2 Backup \
	3 Restore \
	4 Exit 2>ans

menu=`cat ans`

if [ $menu = "1" ]; then
dialog --backtitle "pdaXrom Maintenance Menu" --msgbox "Note: All data on your NAND will be deleted" 10 25
dialog --backtitle "pdaXrom Maintenance Menu" --menu "Where is your installer files?" 10 27 2 1 SD 2 CF 2>ans1
	fi
		menu1=`cat ans1`
		if [ $menu1 = "1" ]; then
		dialog --infobox "Installing pdaXrom, Please wait..." 10 27
		mount /mnt/card
		sh /mnt/card/autoboot.sh /mnt/card/
		dialog --msgbox "Done" 10 10
		fi
	
		if [ $menu1 = "2" ]; then
		dialog --infobox "Installing pdaXrom, Please wait..." 10 27
		pccardctl eject
		sleep 5
		pccardctl insert
		sleep 5
		mount /mnt/cf
		sh /mnt/cf/autoboot.sh /mnt/cf
		dialog --msgbox "Done" 10 10
		fi		
		
if [ $menu = "2" ]; then
dialog --backtitle "pdaXrom Maintenance Menu" --nocancel --menu "Perform Backup?" 10 27 2 \
	1 Yes \
	2 No 2>ans2
	fi
		menu2=`cat ans2`
		if [ $menu2 = "1" ]; then
		dialog --backtitle "pdaXrom Maintenance Menu" --menu "Where to place backup?" 10 27 2 1 SD 2 CF 2>ans3
fi
			menu3=`cat ans3`
			if [ $menu3 = "1" ]; then
			dialog --infobox "Creating Backup to SD Please Wait" 10 27
			dd if=/dev/mtdblock2 of=/mnt/card/backup.pxr
			dialog --msgbox "Backup to SD Complete" 10 27
			fi
			if [ $menu3 = "2" ]; then
			dialog --infobox "Creating Backup to CF Please Wait" 10 27
			dd if=/dev/mtdblock2 of=/mnt/cf/backup.pxr
			dialog --msgbox "Backup to CF Complete" 10 27
fi

if [ $menu = "3" ]; then
dialog --backtitle "pdaXrom Maintenance Menu" --nocancel --menu "Perform Restore?" 10 27 2 \
        1 Yes \
	2 No 2>ans4
fi
                menu4=`cat ans4`
		if [ $menu4 = "1" ]; then
		dialog --backtitle "pdaXrom Maintenance Menu" --menu "Where is your backup?" 10 27 2 1 SD 2 CF 2>ans5
		fi
			menu5=`cat ans5`
			if [ $menu5 = "1" ]; then
			dialog --infobox "Restoring Backup from SD Please Wait" 10 27
			dd if=/mnt/card/backup.pxr of=/dev/mtdblock2
			dialog --msgbox "Restoring Backup Complete" 10 27
			fi
			if [ $menu5 = "2" ]; then
			dialog --infobox "Restoring Backup from CF Please Wait" 10 27
			dd if=/mnt/cf/backup.pxr of=/dev/mtdblock2
			dialog --msgbox "Restoring Backup Complete" 10 27
			fi
if [ $menu = "4" ]; then
end="stop"
fi

done
rm -f ans
clear
exit 0
