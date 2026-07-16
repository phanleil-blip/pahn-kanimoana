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
# Audio capture
# ------------------------------------------------------------

# Record for 26-minute (1560 seconds) wav file at 48 kHz with 16-bit resolution.

cd /media/DATA

# ------------------------------------------------------------
# LED Recording Indicator
# ------------------------------------------------------------

# GPIO23 is physical pin 16.
# Connect the other LED wire to a true ground pin,
# such as physical pin 14.

LED_GPIO=23

blink_recording_led() {
    # Allow arecord below to begin recording first.
    sleep 1

    # Confirm that the Bookworm GPIO command is installed.
    if ! command -v pinctrl >/dev/null 2>&1; then
        echo "WARNING: pinctrl not found; LED was not activated at $(date)" \
            >> "${RUNFILE}"
        return
    fi

    echo "Recording indicator started at $(date)" >> "${RUNFILE}"

    # Configure GPIO23 as an output and begin with LED off.
    pinctrl set "${LED_GPIO}" op dl

    # Blink 10 times:
    # 0.25 seconds on + 0.25 seconds off = 0.5 seconds
    # 10 flashes = 5 seconds total.
    FLASH_COUNT=0

    while [ "${FLASH_COUNT}" -lt 10 ]; do
        pinctrl set "${LED_GPIO}" op dh
        sleep 0.25

        pinctrl set "${LED_GPIO}" op dl
        sleep 0.25

        FLASH_COUNT=$((FLASH_COUNT + 1))
    done

    # Ensure the LED stays off after blinking.
    pinctrl set "${LED_GPIO}" op dl

    echo "Recording indicator finished at $(date)" >> "${RUNFILE}"
}

# Run only the LED function in the background.
blink_recording_led &

arecord -D sysdefault:CARD=sndrpihifiberry -r 48000 -d 1560 -f S16_LE -t wav -V mono KaniMoana1.$(date +%y%m%d%H%M%S).wav

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
