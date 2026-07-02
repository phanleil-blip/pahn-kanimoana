#!/bin/bash

#  KaniMoana.sh
#
#
#  Author: Leilani Phan (phanleil@hawaii.edu)
#  Last Edit: 07/02/2026
#  Script to schedule wittyPi and record audio
#
# ------------------------------------------------------------
# Setup Environment
# ------------------------------------------------------------

echo ""

echo "Welcome to KaniMoana"
echo "Current Time:" $(date)

# ------------------------------------------------------------
# Set Low Voltage Threshold
# ------------------------------------------------------------

cd /home/pi/wittypi/
printf '7\n0\n11\n' | sudo ./wittyPi.sh 
printf '8\n0\n11\n' | sudo ./wittyPi.sh

# ------------------------------------------------------------
# Mount USB
# ------------------------------------------------------------

cd /home/pi/kanimoana

sudo mount /dev/sda1 /media/DATA -o uid=pi,gid=pi
USBID="sda1" && sudo echo sda1 > usb_id.txt
USBNAME=$(sudo blkid | grep $USBID | cut -b 27-31)

# ------------------------------------------------------------
# Create .log file
# ------------------------------------------------------------

echo ""
echo "Create .log"

RUNFILE="KaniMoana3.log"

cd /media/DATA && echo "Start Time of KaniMoana.sh" $(date) >> "${RUNFILE}"

# ------------------------------------------------------------
# Adjust Gain
# ------------------------------------------------------------

# Boost the hydrophone signal as it is very low.

# The values of this command are steps between 0 and 104 and will set ADC volume 0.5db/step. So 96 is about 48dB. You may adjust this value to a lower level depending on the sensitivity.

echo ""
echo "Adjust Gain:"
cd /media/DATA && sudo echo "ADC gain: 48 dB" >> "${RUNFILE}"
amixer -D sysdefault -c sndrpihifiberry cset name='ADC Capture Volume' 96,96

# ------------------------------------------------------------
# USB Name
# ------------------------------------------------------------

echo ""
cd /media/DATA && echo "Data stored to:" $USBNAME
cd /media/DATA && sudo echo "Data stored to:" $USBNAME >> "${RUNFILE}"

# ------------------------------------------------------------
# Schedule Next Start-Up
# ------------------------------------------------------------

echo ""
echo "Schedule Next Start-Up:"

cd /home/pi/wittypi/schedules && sudo cp KaniMoana_4m.wpi /home/pi/wittypi/schedule.wpi
cd /home/pi/wittypi && sudo ./runScript.sh

echo "RPi scheduled to turn back on the half-hour from KaniMoana.sh"
cd /media/DATA && echo "RPi scheduled to turn back on half-hour from KaniMoana.sh at:" $(date) >> "${RUNFILE}"

# ------------------------------------------------------------
# Get Input and Output Voltage
# ------------------------------------------------------------

. /home/pi/wittypi/utilities.sh

echo ""
echo "Getting voltages, temperature and current from wittyPi..."

cd /home/pi/wittypi && v_in="$(get_input_voltage)"
cd /media/DATA && sudo echo "wittyPi Input Voltage at" $(date +%T)":" $v_in >> "${RUNFILE}"

cd /home/pi/wittypi && v_out="$(get_output_voltage)"
cd /media/DATA && sudo echo "wittyPi Output Voltage at" $(date +%T)":" $v_out >> "${RUNFILE}"

# ------------------------------------------------------------
# Temperature
# ------------------------------------------------------------

. /home/pi/wittypi/utilities.sh

cd /home/pi/wittypi && temp="$(get_temperature)"
cd /media/DATA && sudo echo "wittyPi Temperature at" $(date +%T)":" $temp >> "${RUNFILE}"

# ------------------------------------------------------------
# Get Output Current
# ------------------------------------------------------------

. /home/pi/wittypi/utilities.sh

cd /home/pi/wittypi && c_out="$(get_output_current)"
cd /media/DATA && sudo echo "wittyPi Output Current at" $(date +%T)":" $c_out >> "${RUNFILE}"

# ------------------------------------------------------------
# Audio Recording for 26 minutes
# ------------------------------------------------------------

cd /home/pi/kanimoana
sudo ./audio_recording.sh

# ------------------------------------------------------------
# Check USB space
# ------------------------------------------------------------

cd /home/pi/kanimoana && sudo rm usb_space.txt
du -s /media/DATA | grep -o -E '[0-9]+' > /home/pi/kanimoana/usb_space.txt

cd /home/pi/kanimoana
if [ $(cat usb_space.txt) -ge 494085041152 ]; then
  echo ""
  echo $USBNAME "is full"
  if [ $USBID = "sda1" ]; then
    sudo rm usb_id.txt && sudo echo sdb1 > usb_id.txt
    sudo umount -f /dev/$USBID

    USBID=$(cat usb_id.txt)
    sudo mount /dev/$USBID /media/DATA -o uid=pi,gid=pi
    USBNAME=$(sudo blkid | grep $USBID | cut -b 19-23)
  elif [ $USBID = "sdb1" ]; then
    sudo rm usb_id.txt && sudo echo sdc1 > usb_id.txt
    sudo umount -f /dev/$USBID

    USBID=$(cat usb_id.txt)
    sudo mount /dev/$USBID /media/DATA -o uid=pi,gid=pi
    USBNAME=$(sudo blkid | grep $USBID | cut -b 19-23)
  elif [ $USBID = "sdc1" ]; then
    sudo rm usb_id.txt && sudo echo FULL > usb_id.txt
    sudo umount -f /dev/$USBID

    $USBNAME="Native"

    cd /media && mkdir DATA
    cd /media/DATA
  fi
fi

# ------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------

echo ""
echo "Cleaning up..."

# Write .log
cd /media/DATA && sudo echo "End Time of KaniMoana.sh" $(date) >> "${RUNFILE}"

# Copy wittyPi logs to USB
sudo cp /home/pi/wittypi/wittyPi.log /media/DATA/
sudo cp /home/pi/wittypi/schedule.log /media/DATA/

# ------------------------------------------------------------
# Exit
# ------------------------------------------------------------

echo "Exit KaniMoana.sh "
echo ""
exit 0
