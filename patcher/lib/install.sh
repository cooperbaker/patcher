#!/bin/bash
#-------------------------------------------------------------------------------
# install.sh
#
# Patcher Install Script For RNBO Raspbian OS
#
# 1. Follow skronk sd card flashing instructons in README.md
# 2. Run this command from a fresh OS image to install patcher:
# $  curl https://raw.githubusercontent.com/cooperbaker/patcher/refs/heads/main/patcher/lib/install.sh | bash
#
# Cooper Baker (c) 2024
# http://nyquist.dev/patcher
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# install skronk
#-------------------------------------------------------------------------------
sudo echo ""
echo -e "\033[1mInstalling Patcher"
echo -e "\033[0m\033[1A"
echo ""


#-------------------------------------------------------------------------------
# update packages
#-------------------------------------------------------------------------------
echo -e "\033[1mUpdating Package Lists..."
echo -e "\033[0m\033[1A"
echo ""
sudo apt -y update
echo ""


#-------------------------------------------------------------------------------
# install packages
#-------------------------------------------------------------------------------
echo -e "\033[1mInstalling Packages..."
echo -e "\033[0m\033[1A"
echo ""
# sudo apt -y install jack_transport_link
# sudo apt -y install rnbo-runner-panel
sudo apt -y install libasound2-dev
sudo apt -y install python3-smbus
sudo apt -y install puredata
sudo apt -y install neofetch
sudo apt -y install git
sudo apt -y install zsh
echo ""


#-------------------------------------------------------------------------------
# upgrade packages
#-------------------------------------------------------------------------------
echo -e "\033[1mUpgrading Packages..."
echo -e "\033[0m\033[1A"
echo ""
sudo apt -y update
sudo apt -y upgrade
sudo apt -y clean
sudo apt -y autoremove
sudo apt -y autoclean
echo ""


#-------------------------------------------------------------------------------
# install patcher firmware
#-------------------------------------------------------------------------------
echo -e "\033[1mInstalling Patcher Firmware..."
echo -e "\033[0m\033[1A"
echo ""
cd /home/pi
sudo rm -rf patcher
git clone --depth 1 https://github.com/cooperbaker/patcher /home/pi/patcher
chmod -Rv 755 ./patcher/patcher/lib

# compile and install device tree overlay for audio
cd /home/pi/patcher/patcher/lib
dtc -@ -H epapr -O dtb -o audio.dtbo -Wno-unit_address_vs_reg audio.dts
sudo cp -v audio.dtbo /boot/overlays/
rm -v audio.dtbo

# compile midi driver
gcc midi.c -v -o midi -lasound -lpthread
echo ""


#-------------------------------------------------------------------------------
# install patcher-pd patches to /home/pi/pd
#-------------------------------------------------------------------------------
# echo -e "\033[1mInstalling Patcher Pd Patches..."
# echo -e "\033[0m\033[1A"
# echo ""
# cd /home/pi
# sudo rm -rf pd
# git clone --depth 1 https://github.com/cooperbaker/patcher-pd /home/pi/pd
# echo ""


#-------------------------------------------------------------------------------
# enable i2c and spi
#-------------------------------------------------------------------------------
#
#  WHAT ABOUT I2S ???
#
echo -e "\033[1mEnabling I2C and SPI..."
echo -e "\033[0m\033[1A"
echo ""
echo "sudo raspi-config nonint do_i2c 0"
echo "sudo raspi-config nonint do_spi 0"
sudo raspi-config nonint do_i2c 0
sudo raspi-config nonint do_spi 0
echo ""


#-------------------------------------------------------------------------------
# configure zsh
#-------------------------------------------------------------------------------
echo -e "\033[1mConfiguring ZSH..."
echo -e "\033[0m\033[1A"
echo ""
sudo chsh -s /usr/bin/zsh pi
sudo chsh -s /usr/bin/zsh root
ln -sv /home/pi/patcher/patcher/lib/zshrc .zshrc
sudo ln -sv /home/pi/patcher/patcher/lib/zshrc /root/.zshrc
echo ""


#-------------------------------------------------------------------------------
# edit /boot/firmware/config.txt
#-------------------------------------------------------------------------------
echo -e "\033[1mEditing /boot/firmware/config.txt..."
echo -e "\033[0m\033[1A"
echo ""
sudo rsync -auv /boot/firmware/config.txt /boot/firmware/config.txt.original
# add 'dtparam...' if 'dtparam...' does not exist
sudo grep -qxF 'dtparam=uart4-pi5' /boot/firmware/config.txt || echo 'dtparam=uart4-pi5' | sudo tee -a /boot/firmware/config.txt
sudo grep -qxF 'dtoverlay=midi-uart4-pi5' /boot/firmware/config.txt || echo 'dtoverlay=midi-uart4-pi5' | sudo tee -a /boot/firmware/config.txt
sudo grep -qxF 'dtoverlay=audio' /boot/firmware/config.txt || echo 'dtoverlay=audio' | sudo tee -a /boot/firmware/config.txt
echo ""

#-------------------------------------------------------------------------------
# create patcher service
#-------------------------------------------------------------------------------
# echo -e "\033[1mCreating Patcher Service..."
# echo -e "\033[0m\033[1A"
# echo ""
# sudo systemctl disable patcher.service
# sudo ln -sv /home/pi/patcher/patcher/lib/patcher.service /etc/systemd/system/patcher.service
# sudo systemctl enable patcher.service
# sudo systemctl daemon-reload
# sudo systemctl start patcher.service
# sudo systemctl status patcher.service
# echo ""


#-------------------------------------------------------------------------------
# install complete
#-------------------------------------------------------------------------------
echo -e "\033[1mPatcher Install Complete"
echo -e "\033[0m\033[1A"
echo ""
cd

#-------------------------------------------------------------------------------
# eof
#-------------------------------------------------------------------------------