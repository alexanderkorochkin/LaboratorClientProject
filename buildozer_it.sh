#!/bin/bash

cd $HOME/dev	
#Need to be in every file, where configuration used
CFG_FILE=build_config.cfg
CFG_CONTENT=$(cat $CFG_FILE | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g')
eval "$CFG_CONTENT"

source $DROOT/ceho.sh

VENV_CHECK_VALUE=0

venv_check ()
{
	if [[ "$VIRTUAL_ENV" != "" ]]
	then
		ceho greely "VIRTUALENV:($VIRTUAL_ENV) is applied!"
		VENV_CHECK_VALUE=1
	else
		ceho redly "VIRTUALENV not applied!"
		VENV_CHECK_VALUE=0
	fi
}

buildozer_it ()
{
	cd $DROOT/${app_name}Project
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
	ceho colly "......BUILDING COMPLETED......"

}

if [ $# -eq 1 ]; then
	if [ $1 == "-run" ]; then
		venv_check
		buildozer_it
	fi
fi
