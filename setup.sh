#!/bin/bash
#
# setup.sh v1.1 030724ZJAN25
# 
# added screen 
#
echo -e "\e[36m\n-*-*-*-*-*-*-*-*-*-*-*-*-*-*-\e[0m"
echo -e "\e[37m28tauri's raspbian setup script v1.3\n\e[0m"
echo -e "\e[36m-*-*-*-*-*-*-*-*-*-*-*-*-*-*-\n\e[0m"

echo -e "\e[1;33m\nfirst, we update!\n\e[0m"
sudo apt-get update && sudo apt-get upgrade -y 

echo -e "\e[1;33m\ninstalling build stuff and git (probably already here but need to make sure)\n\e[0m"
sudo apt-get install make cmake build-essential git -y

echo -e "\e[1;33m\ninstalling python and pip (probably already here but need to make sure)\n\e[0m"
sudo apt-get install python3 python3-pip -y

echo -e "\e[1;33m\ninstalling some random fun stuff\n\e[0m"
sudo apt-get install neofetch screen -y

echo -e "\e[1;33m\ngoing to try editing bashrc now\n\e[0m"
cat << EOF >> ~/.bashrc
alias ..='cd ..'
alias ll='ls -lASh'
alias update='sudo apt update && sudo apt upgrade -y'
alias hs='history | grep $1'
alias snano='sudo nano'
alias please='sudo'
alias temp='vcgencmd measure_temp'
EOF

echo -e "\e[1;33m\nwant to install rtl-sdr stuff? y/n\n\e[0m"
read rtlsdrreqs
if [ $rtlsdrreqs == "y" ]; then 
	sudo apt-get install rtl-sdr rtl-433 -y 
fi

echo -e "\e[1;33m\nis this an adsb feeder? y/n\n\e[0m"
read adsbreqs
if [ $adsbreqs == "y" ]; then 
	echo -e "\e[1;33m\nenter latitude decimal degrees\n\e[0m"
	read adsblat
	echo -e "\e[1;33m\nenter longitude decimal degrees\n\e[0m"
	read adsblong
	echo -e "\e[1;33m\nenter altitude in meters\n\e[0m"
	read adsbalt
	echo -e "\e[1;33m\ninstalling wiedehopf's readsb, autogain, graphs package, autogain, and feeding adsbexchange and airplanes.live\n\e[0m"
	sudo bash -c "$(wget -O - https://github.com/wiedehopf/adsb-scripts/raw/master/readsb-install.sh)"
	sudo readsb-set-location $adsblat $adsblong
	sudo bash -c "$(curl -L -o - https://github.com/wiedehopf/adsb-scripts/raw/master/autogain-install.sh)"
	hash -r
	sudo autogain1090
	sudo bash -c "$(curl -L -o - https://github.com/wiedehopf/graphs1090/raw/master/install.sh)"
	curl -L -o /tmp/axfeed.sh https://www.adsbexchange.com/feed.sh
	sudo bash /tmp/axfeed.sh
	curl -L -o /tmp/feed.sh https://raw.githubusercontent.com/airplanes-live/feed/main/install.sh
	sudo bash /tmp/feed.sh
	echo -e "\e[1;33m\nokay, feeder should be up locally at <ip>/tar1090\n\e[0m"
	echo -e "\e[1;33m\nalso check both https://www.adsbexchange.com/myip/ and https://airplanes.live/myfeed/\n\e[0m"
	echo -e "\e[1;33m\nmoving on!\n\e[0m"
fi

echo -e "\e[1;33m\ninstall meshtastic cli? y/n\n\e[0m"
read meshpy
if [ $meshpy == "y" ]; then 
	echo -e "\e[1;33m\nadding user to relevant groups for serial access\n\e[0m"
	sudo usermod -aG dialout $USER
	sudo usermod -aG tty $USER
	sudo usermod -aG bluetooth $USER
	echo -e "\e[1;33m\ninstalling pytap2 and meshtastic cli. this should work fine on everything up to and including bullseye. bookworm changed venv stuff\n\e[0m"
	pip3 install --upgrade pytap2
	pip3 install --upgrade "meshtastic[cli]"
	echo -e "\e[1;33m\nignore the PATH error; meshtastic runs in venv anyway\n\e[0m"
fi

echo -e "\e[37m\nscript completed!\n\e[0m"
exit 0
