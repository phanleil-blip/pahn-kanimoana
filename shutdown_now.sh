#!/bin/sh

#  shutdown_now.sh
#
#
#  Author: Camille Pagniello (cpagniel@stanford.edu)
#  Last Edit: 05/07/2022
#  Script to shutdown RPi

# ------------------------------------------------------------
# Setup Environment
# ------------------------------------------------------------

echo ""
echo "RPi will shutdown in 5 seconds."

sleep 5

# ------------------------------------------------------------
# Create .log file
# ------------------------------------------------------------

RUNFILE="KaniMoana3.log"

# ------------------------------------------------------------
# Shutdown RPi
# ------------------------------------------------------------

cd /media/DATA && echo "RPi shutdown at:" $(date) >> "${RUNFILE}"
cd /media/DATA && echo "" >> "${RUNFILE}"

sudo shutdown -h now
