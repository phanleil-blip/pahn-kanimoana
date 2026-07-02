#!/bin/bash

#  install_KaniMoana.sh
#
#
#  Author: Camille Pagniello (cpagniel@stanford.edu)
#  Last Edit: 05/07/2022
#  Script to download, install and configure KaniMoana
#

echo "Welcome to KaniMoana"
echo "Beginning installation..."
echo ""

# ------------------------------------------------------------
# Update and Upgrade Bookworm OS
# ------------------------------------------------------------

echo "Updating and upgrading Bookworm OS..."
echo ""

sudo apt-get update
sudo apt update
echo "Y" | sudo apt upgrade

# ------------------------------------------------------------
# Configure TimeZone RaspberryPi
# ------------------------------------------------------------

echo ""
echo "Configuring RPi time zone..."
echo "Set timezone to US/Hawaii."
echo ""
sudo timedatectl set-timezone US/Hawaii

# ------------------------------------------------------------
# Install WittyPi3
# ------------------------------------------------------------

echo "Installing WittyPi3..."
echo ""

cd /home/pi
sudo wget http://www.uugear.com/repo/WittyPi3/install.sh
sudo sh install.sh

echo "Y" | rm install.sh

# ------------------------------------------------------------
# Install WiringPi
# ------------------------------------------------------------

echo "Installing WiringPi..."
echo ""

cd /home/pi
git clone https://github.com/WiringPi/WiringPi.git

cd WiringPi
./build

# ------------------------------------------------------------
# Configure USB Mount Location
# ------------------------------------------------------------

echo "Creating USB mount location..."
echo ""

cd /media
sudo mkdir DATA
sudo chown -R pi:pi /media/DATA

# ------------------------------------------------------------
# Configure KaniMoana Directories
# ------------------------------------------------------------

echo "Creating directories for KaniMoana..."
echo ""

cd /home/pi
sudo mkdir kanimoana

cd /home/pi/kanimoana
mkdir config

# ------------------------------------------------------------
# Get KaniMoana Configuration Files from GitHub
# ------------------------------------------------------------

echo "Downloading KaniMoana configuration files from GitHub..."
echo ""

cd /home/pi/kanimoana/config

sudo wget https://raw.githubusercontent.com/phanleil-blip/pahn-kanimoana/main/software/config/asound.conf
sudo cp asound.conf /etc

# ------------------------------------------------------------
# Get KaniMoana Software from GitHub
# ------------------------------------------------------------

echo "Downloading KaniMoana software from GitHub..."
echo ""

cd /home/pi/kanimoana

sudo wget https://raw.githubusercontent.com/phanleil-blip/pahn-kanimoana/main/software/scripts/KaniMoana.sh
sudo chmod +x KaniMoana.sh

sudo wget https://raw.githubusercontent.com/phanleil-blip/pahn-kanimoana/main/software/scripts/audio_recording.sh
sudo chmod +x audio_recording.sh

sudo wget https://raw.githubusercontent.com/phanleil-blip/pahn-kanimoana/main/software/scripts/shutdown_now.sh
sudo chmod +x shutdown_now.sh

# ------------------------------------------------------------
# Get and Install KaniMoana Scheduling Files from GitHub
# ------------------------------------------------------------

echo "Downloading WittyPi schedule file..."
echo ""

cd /home/pi/wittypi/schedules
sudo rm -f *.wpi

sudo wget -O KaniMoana_4m.wpi https://raw.githubusercontent.com/phanleil-blip/pahn-kanimoana/main/software/wittypi/KaniMoana_4m.wpi

sudo cp KaniMoana_4m.wpi /home/pi/wittypi/schedule.wpi

cd /home/pi/wittypi
sudo ./runScript.sh

# ------------------------------------------------------------
# Edit .bashrc
# ------------------------------------------------------------

echo "Editing .bashrc..."
echo ""

cd /home/pi

sudo echo "" >> .bashrc
sudo echo "# Audio Capture for KaniMoana" >> .bashrc
sudo echo "" >> .bashrc
sudo echo "sleep 10" >> .bashrc
sudo echo "" >> .bashrc
sudo echo "cd /home/pi/kanimoana" >> .bashrc
sudo echo "sudo ./KaniMoana.sh" >> .bashrc
sudo echo "# wittyPi Scheduling and Shutdown Sequence for KaniMoana"
sudo echo "sudo ./shutdown_now.sh"  >> .bashrc

# ------------------------------------------------------------
# Shutdown to Add WittyPi & HifiBerry
# ------------------------------------------------------------

sleep 5

echo "Installation sucessful!"
echo ""

echo "Shutting down to add WittyPi & HifiBerry hats."
echo ""

sudo shutdown -h now
