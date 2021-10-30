#!/bin/bash

cd $HOME/dev	
#Need to be in every file, where configuration used
CFG_FILE=build_config.cfg
CFG_CONTENT=$(cat $CFG_FILE | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g')
eval "$CFG_CONTENT"

source $DROOT/git_update.sh
source $DROOT/ceho.sh
source $DROOT/buildozer_it.sh

VENV_CHECK_VALUE=0

venv_check ()
{
	if [[ "$VIRTUAL_ENV" != "" ]]
	then
		#ceho greely "VIRTUALENV:($VIRTUAL_ENV) is applied!"
		VENV_CHECK_VALUE=1
	else
		ceho redly "VIRTUALENV is not applied!"
		VENV_CHECK_VALUE=0
	fi
}

ceho colly "Make requirements file before installation: pip freeze | Out-File -Encoding UTF8 requirements.list" 1s

#run script by: source BUILD.sh firstly
ceho greely "Starting..."

cd ${DROOT}
if ! [ -d ${app_name}Project ];
then
	ceho colly "First run detected! Setting up venv in directory..." 1s
	mkdir ${app_name}Project && ceho greely "[GOOD]: Directory ${app_name}Project created!"
	cd ${app_name}Project
	ceho colly "Working on VENV..."
	sudo apt update
	sudo apt install -y $python_version-virtualenv
	$python_version -m virtualenv $app_name && ceho greely "Successfully created virtual environment ($app_name)!"
	cd ${DROOT}
	ceho greely "First stage of preparing finished! Run script again!"
fi
cd ${app_name}Project
if ! [ -d ./buildozer ];
then
	ceho colly "First assembling detected!"
	ceho colly "Installing and upgrading all dependencies..."
	if [ -e /usr/bin/apt ];
	then
		sudo apt update
		sudo apt install -y curl
		sudo apt install -y ${python_version}-distutils
		sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
		$python_version get-pip.py
			
		ceho colly "Installing and upgrading SDL2 dependencies..."
		# Dependencies with SDL2
		# Install necessary system packages
		sudo apt-get install -y \
    			python-pip \
    			build-essential \
    			git \
    			python3 \
			python3-dev \
    			ffmpeg \
    			libsdl2-dev \
    			libsdl2-image-dev \
    			libsdl2-mixer-dev \
    			libsdl2-ttf-dev \
    			libportmidi-dev \
    			libswscale-dev \
    			libavformat-dev \
    			libavcodec-dev \
    			zlib1g-dev
		ceho greely "SDL2 dependencies is good!"
	elif [ -e /usr/bin/pacman ];
	then
		sudo pacman -Syu #make sure repos are up to date and no partial upgrades occur
		sudo pacman -S --noconfirm curl python-distutils-extra python-pip
		sudo pacman -S --noconfirm base-devel python ffmpeg sdl2 sdl2_image sdl2_mixer sdl2_ttf portmidi zlib
	else
		sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
		$python_version get-pip.py
	fi

	# Dependencies Buildozer
	if [ -e /usr/bin/apt ];
	then	
		ceho colly "Installing and upgrading Buildozer dependencies..."
		sudo apt install -y \
    			build-essential \
    			ccache \
    			git \
    			libncurses5:i386 \
    			libstdc++6:i386 \
    			libgtk2.0-0:i386 \
    			libpangox-1.0-0:i386 \
    			libpangoxft-1.0-0:i386 \
    			libidn11:i386 \
    			python2.7 \
    			python2.7-dev \
    			openjdk-8-jdk \
    			unzip \
    			zlib1g-dev \
    			zlib1g:i386 \
    			libltdl-dev \
    			libffi-dev \
    			libssl-dev \
    			autoconf \
    			autotools-dev \
			lld \
    			cmake
		ceho greely "Buildozer dependencies is good!"
	fi
	if [ -e /usr/bin/pacmann ]; then
		#this requeires the multilib repo to be enabled
		sudo pacman -S --noconfirm base-devel ccahe git ncurses lib32-ncurses libstdc++5 gtk2 lib32-gtk2 lib32-pango lib32-libidn11  jdk8-openjdk unzip zlib lib32-zlib lib32-libltdl libffi openssl autoconf cmake
	fi

	#ceho greely "Installing Ruby, Bundler"
	#sudo apt install -y ruby
	#sudo gem install bundler
	#bundle config set --local path 'vendor/bundle'
	
	ceho greely "All dependencies are installed! Second stage of preparing are ended! Run script again as: source $0!"
	
fi

cd $DROOT/${app_name}Project
venv_check
if [ $VENV_CHECK_VALUE -eq 0 ]; then
	source $app_name/bin/activate
fi

venv_check
if [ $VENV_CHECK_VALUE -eq 0 ]; then
	ceho redly "Unable to activate virtual environment..."
	exit 1
fi

if ! [ -d ./buildozer ]; then
	ceho colly "Installing and upgrading Cython and Kivy..."
	pip3 install --upgrade cython kivy && ceho greely "Cython and Kivy is good!"
	ceho colly "Installing Buildozer..."
	git clone https://github.com/kivy/buildozer.git
	cd buildozer || return 1
	$python_version setup.py install
	ceho greely "Buildozer is good!"
	cd ..
fi

git_download

cd $DROOT/${app_name}Project
ceho colly "Working at buildozer.spec file..."
rm -f buildozer.spec
buildozer init

sed -i "s/title = .*/title = $app_name/" buildozer.spec
sed -i "s/package.name = .*/package.name = $package_name/" buildozer.spec
sed -i "s/package.domain = .*/package.domain = $package_domain/" buildozer.spec
sed -i "s/#android.permissions = .*/android.permissions = $android_permissions/" buildozer.spec
sed -i "s/version = .*/version = $app_version/" buildozer.spec
sed -i "s/android.arch = .*/android.arch = $app_arch/" buildozer.spec
sed -i "s/#p4a.branch = .*/p4a.branch = master/" buildozer.spec

ceho colly "Generating requirements from requirements.list file..."
requirements=''
isFirst=true
sed -i '1s/^\xEF\xBB\xBF//' requirements.list
while IFS= read -r line
do
  	if [ "${line:0:4}" != "kivy" ] && [ "${line:0:4}" != "Kivy" ] && [ "${line:0:8}" != "pypiwin3" ] && [ "${line:0:7}" != "pywin32" ];
	then
		if $isFirst
		then
			IFS='='
			set $line
			requirements="${1}"
			isFirst=false
		else
			IFS='='
			set $line
			requirements="$requirements,${1}"
		fi
	fi
done < requirements.list
unset IFS

sed -i "s/requirements = .*/requirements = $requirements_default,$requirements/" buildozer.spec
ceho colly "Modules required: $requirements_default,$requirements"

requirements_spaces=$(echo "${requirements}" | tr , ' ')
	
ceho colly "Installing and upgrading requirements..."
command="pip3 install --upgrade $requirements_spaces"
eval $command
ceho greely "___PREPARING DONE___"
cd $DROOT

venv_check
if [ $VENV_CHECK_VALUE -eq 1 ]; then
	eval "./buildozer_it.sh -run"
fi

cd $DROOT/${app_name}Project/bin
ceho greely "___BUILD SUCCESSFULLY DONE___"

