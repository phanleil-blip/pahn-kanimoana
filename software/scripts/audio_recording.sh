#!/bin/sh

#  audio_recording.sh
#
#
#  Author: Camille Pagniello (cpagniel@stanford.edu)
#  Last Edit: 05/07/2022
#  Script for audio recording
#
# ------------------------------------------------------------
# Setup Environment
# ------------------------------------------------------------

echo ""
echo "Start audio_recording.sh"

# ------------------------------------------------------------
# Write to .log file
# ------------------------------------------------------------

RUNFILE="KaniMoana3.log"

cd /media/DATA && sudo echo "Start Time of audio_recording.sh" $(date) >> "${RUNFILE}"

# ------------------------------------------------------------
# Starting audio capture...
# ------------------------------------------------------------

cd /media/DATA && sudo echo "Start Time of audio capture:" $(date) >> "${RUNFILE}"

# ------------------------------------------------------------
# Audio capture
# ------------------------------------------------------------

# Record for 26-minute (1560 seconds) wav file at 48 kHz with 16-bit resolution.

cd /media/DATA

arecord -D sysdefault:CARD=sndrpihifiberry -r 48000 -d 1560 -f S16_LE -t wav -V mono KaniMoana3.$(date +%y%m%d%H%M%S).wav

# ------------------------------------------------------------
# Ending audio capture...
# ------------------------------------------------------------

cd /media/DATA && sudo echo "End Time of audio capture:" $(date) >> "${RUNFILE}"

# ------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------

echo ""
echo "Cleaning up"

cd /media/DATA && sudo echo "End Time of audio_recording.sh" $(date) >> "${RUNFILE}"

# ------------------------------------------------------------
# Exit
# ------------------------------------------------------------

echo ""
echo "Exit audio_recording.sh"
exit 0
