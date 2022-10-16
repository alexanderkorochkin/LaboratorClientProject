#!/bin/bash

#Need to be in every file, where configuration used
CFG_FILE=build_config.cfg
CFG_CONTENT=$(cat $CFG_FILE | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g')
eval "$CFG_CONTENT"

source ceho.sh

buildozer_it ()
{
	cd ./${app_name}
	ceho colly "BUILDING WITH BUILDOZER..."
	if ! [ -d /.buildozer ];
	then
		ceho colly "Folder .buildozer not found! It looks like this assembly is the first. Run..."		
		yes | buildozer android debug
	else
		ceho colly "Folder .buildozer already exists! Run..."	
		sudo rm -rf .buildozer
		yes | buildozer android debug
	fi
	ceho colly "_____BUILDING COMPLETED_____"
}

if [ $# -eq 1 ]; then
	if [ $1 == "-run" ]; then
		buildozer_it
	fi
fi
