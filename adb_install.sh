#!/bin/bash

source ceho.sh

adb_install() 
{
	sudo ln -s /mnt/c/adb/adb.exe /usr/bin/adb
	SESSION=$(adb devices | grep -oE '[0-9]+')
	while [ "$SESSION" == "" ]
	do
		sleep 3
		ceho colly 'Waiting the device connected...'
		SESSION=$(adb devices | grep -oE '[0-9]+')
	done
	
	adb install $1
	
}

if [ $1 == "-run" ]; then
	#Need to be in every file, where configuration used
	CFG_FILE=build_config.cfg
	CFG_CONTENT=$(cat $CFG_FILE | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g')
	eval "$CFG_CONTENT"
	adb_install $2
fi