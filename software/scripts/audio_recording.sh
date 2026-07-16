#!/bin/sh

#  audio_recording.sh
#
#
#  Author: Leilani Phan (phanleil@hawaii.edu)
#  Last Edit: 07/15/2026
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

RUNFILE="KaniMoana1.log"

cd /media/DATA && sudo echo "Start Time of audio_recording.sh" $(date) >> "${RUNFILE}"

# ------------------------------------------------------------
# Starting audio capture...
# ------------------------------------------------------------

cd /media/DATA && sudo echo "Start Time of audio capture:" $(date) >> "${RUNFILE}"

# ------------------------------------------------------------
# Audio Capture with Recording-Start Indicator
# ------------------------------------------------------------

cd /media/DATA || {
    echo "ERROR: Could not access /media/DATA"
    exit 1
}

# GPIO23 is physical pin 16 on the Raspberry Pi/HiFiBerry header.
LED_GPIO=23

# Create the filename before starting arecord.
FILENAME="KaniMoana1.$(date +%y%m%d%H%M%S).wav"

# Make sure the indicator begins in the OFF state.
if command -v pinctrl > /dev/null 2>&1; then
    pinctrl set "${LED_GPIO}" op dl
    LED_AVAILABLE=true
else
    LED_AVAILABLE=false
    echo "WARNING: pinctrl was not found. LED indicator disabled." \
        >> "${RUNFILE}"
fi

# Start arecord in the background.
arecord \
    -D sysdefault:CARD=sndrpihifiberry \
    -r 48000 \
    -d 1560 \
    -f S16_LE \
    -t wav \
    -V mono \
    "${FILENAME}" &

# Save the arecord process ID.
ARECORD_PID=$!

# Give arecord time to initialize the HiFiBerry and WAV file.
sleep 1

# Confirm that:
# 1. arecord is still running
# 2. the WAV file exists and is not empty
if kill -0 "${ARECORD_PID}" 2>/dev/null && [ -s "${FILENAME}" ]; then

    echo "arecord started successfully at $(date)" \
        >> "${RUNFILE}"

    echo "Recording file created: ${FILENAME}" \
        >> "${RUNFILE}"

    # Blink the indicator for five seconds.
    if [ "${LED_AVAILABLE}" = true ]; then

        echo "Recording indicator started at $(date)" \
            >> "${RUNFILE}"

        FLASH=0

        while [ "${FLASH}" -lt 10 ]; do

            # LED on.
            pinctrl set "${LED_GPIO}" op dh
            sleep 0.25

            # LED off.
            pinctrl set "${LED_GPIO}" op dl
            sleep 0.25

            FLASH=$((FLASH + 1))
        done

        # Keep the indicator off during the rest of recording.
        pinctrl set "${LED_GPIO}" op dl

        echo "Recording indicator finished at $(date)" \
            >> "${RUNFILE}"
    fi

else

    echo "ERROR: arecord did not start correctly at $(date)" \
        >> "${RUNFILE}"

    if [ "${LED_AVAILABLE}" = true ]; then
        pinctrl set "${LED_GPIO}" op dl
    fi

fi

# Wait for the complete 26-minute recording to finish.
wait "${ARECORD_PID}"
ARECORD_STATUS=$?

# Make sure the indicator is off after recording.
if [ "${LED_AVAILABLE}" = true ]; then
    pinctrl set "${LED_GPIO}" op dl
fi

# Log the final result.
if [ "${ARECORD_STATUS}" -eq 0 ]; then

    echo "arecord completed successfully at $(date)" \
        >> "${RUNFILE}"

    echo "Final audio file: ${FILENAME}" \
        >> "${RUNFILE}"

else

    echo "ERROR: arecord exited with status ${ARECORD_STATUS} at $(date)" \
        >> "${RUNFILE}"

fi

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
