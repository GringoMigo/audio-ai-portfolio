#!/bin/bash
# voice_prep.sh — full voice preparation pipeline
# Usage: bash voice_prep.sh <input_file> <output_file>

INPUT="$1"
OUTPUT="$2"

if [ $# -ne 2 ]; then
  echo "Usage: $0 <input_file> <output_file>"
  echo "Example: $0 raw/voice.wav processed/voice_clean.wav"
  exit 1
fi

[ -f "$INPUT" ] || { echo "Error: file not found: $INPUT"; exit 1; }
mkdir -p "$(dirname "$OUTPUT")"

echo "Processing: $(basename "$INPUT")"
echo "Output:     $(basename "$OUTPUT")"

ERROR=$(ffmpeg -y -v error \
  -i "$INPUT" \
-af "highpass=f=80,\
lowpass=f=8000,\
loudnorm=I=-16:TP=-1.5:LRA=11" \
  -ar 22050 -ac 1 -c:a pcm_s16le \
  "$OUTPUT" 2>&1)

if [ $? -eq 0 ]; then
  DURATION=$(ffprobe -v error -show_entries format=duration \
    -of csv=p=0 "$OUTPUT" | awk '{printf "%.1f", $1}')
  echo "Done. Duration: ${DURATION}s"
  echo "Filters applied: highpass(80Hz) + lowpass(8kHz) + loudnorm(-16 LUFS) + silence trim"
else
  echo "FAILED: $ERROR"
  exit 1
fi
