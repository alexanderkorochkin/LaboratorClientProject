#!/bin/bash

buildozer_it ()
{
	ceho colly "Do not forget to activate VPN!"
	ceho greely "_____BUILDING WITH BUILDOZER_____"

	if ! [ -e .buildozer ];
	then
		ceho colly "Folder .buildozer not found! It looks like this assembly is the first. Run..."		
		yes | buildozer android debug
	else
		ceho colly "Folder .buildozer already exists! Delete and run..."	
		sudo rm -rf .buildozer
		yes | buildozer android debug
	fi
	ceho greely "_____BUILDING COMPLETED_____"
}

if [ $# -eq 2 ]; then
	if [ $1 == "-run" ]; then
		cd $2/${app_name}
		buildozer_it
	fi
fi
