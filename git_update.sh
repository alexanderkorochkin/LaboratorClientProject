#!/bin/bash

source ceho.sh

git_download() 
{
	cd $DROOT/${app_name}Project
	ceho colly "GIT_LINK: $git_link"
	if ! [ -d ./.git ]; then
		ceho colly "Repository (.git) folder has been not found! Cloning from: $git_link"
		cd ..
		git clone $git_link temp
		cp -r temp/. ${app_name}Project
		sudo rm -rf temp
		cd $DROOT/${app_name}Project
		ceho greely "Cloned git from $git_link to: ${app_name}Project"
	else
		ceho colly "Repository folder has been found! Pulling from: $git_link"
		git pull
		ceho greely "Pulled git from $git_link to: ${app_name}Project"
	fi
}

if [ $# -eq 1 ]; then
	if [ $1 == "-run" ]; then
		cd $HOME/dev	
		#Need to be in every file, where configuration used
		CFG_FILE=build_config.cfg
		CFG_CONTENT=$(cat $CFG_FILE | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g')
		eval "$CFG_CONTENT"
		git_update
	fi
fi


