#!/bin/bash

buildozer_it ()
{
	ceho colly "Do not forget to activate VPN!"

	if ! [ -e .buildozer ];
	then
		ceho colly "Folder .buildozer not found! It looks like this assembly is the first. Run..."		
		yes | buildozer android debug
	else
		ceho colly "WARNING! Folder .buildozer already exists! Run..."	
		#sudo rm -rf .buildozer
		yes | buildozer android debug
	fi
}

if [ $# -eq 2 ]; then
	if [ $1 == "-run" ]; then
		cd $2/${app_name}
		buildozer_it
	fi
fi
