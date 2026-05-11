#!/bin/bash

DIR="${1:-.}"
TOTAL=0
SR_44=0
SR_48=0
SR_OTHER=0

echo "=============================="
echo " Audio File Inspector"
echo " Directory: $DIR"
echo "=============================="
echo ""

for FILE in "$DIR"/*.{wav,mp3,aiff,flac,m4a}; do
  [ -f "$FILE" ] || continue
  BASENAME=$(basename "$FILE")
  DURATION=$(ffprobe -v quiet -show_entries format=duration \
    -of csv=p=0 "$FILE" 2>/dev/null | awk '{printf "%.1f", $1}')
  SR=$(ffprobe -v quiet -show_entries stream=sample_rate \
    -of csv=p=0 "$FILE" 2>/dev/null | head -1)
  CH=$(ffprobe -v quiet -show_entries stream=channels \
    -of csv=p=0 "$FILE" 2>/dev/null | head -1)
  CODEC=$(ffprobe -v quiet -show_entries stream=codec_name \
    -of csv=p=0 "$FILE" 2>/dev/null | head -1)

  echo "  $BASENAME"
  echo "    duration=${DURATION}s | sr=${SR}Hz | channels=${CH} | codec=${CODEC}"

  TOTAL=$((TOTAL + 1))
  if [ "$SR" = "44100" ]; then SR_44=$((SR_44 + 1))
  elif [ "$SR" = "48000" ]; then SR_48=$((SR_48 + 1))
  else SR_OTHER=$((SR_OTHER + 1))
  fi
done

echo ""
echo "=============================="
echo " SUMMARY"
echo " Total files : $TOTAL"
echo " 44100 Hz    : $SR_44"
echo " 48000 Hz    : $SR_48"
echo " Other SR    : $SR_OTHER"
echo "=============================="
