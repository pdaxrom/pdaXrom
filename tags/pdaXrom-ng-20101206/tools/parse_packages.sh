#!/bin/bash
echo "****************************************
This script is used to export package data to a delimited file and will include Package Name, Package Version and Package Details. 
THIS PACKAGE SHOULD BE LAUNCHED FROM THE ROOT OF THE BUILD ENV!!!!!!
******************************************"
> dump.csv
for i in `ls rules/ |egrep -v 'NEW|create|template'|cut -d'.' -f1`; do \
	packagename=$i  
	packageversion=`grep -i ^${i}_VERSION rules/$i.sh|cut -d'=' -f2`; 
		echo "$packagename;$packageversion" >> dump.csv; 
done
