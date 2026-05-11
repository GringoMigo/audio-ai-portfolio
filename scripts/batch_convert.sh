#!/bin/bash
INPUT="${1}"
OUTPUT="${2}"

if [ $# -ne 2 ]; then
  echo "Usage: $0 <input_dir> <output_dir>"
  echo "Example: $0 test-audio/raw test-audio/processed"
  exit 1
fi

[ -d "$INPUT" ] || { echo "Error: input folder not found: $INPUT"; exit 1; }
mkdir -p "$OUTPUT"

OK=0
FAIL=0
SKIP=0

echo "=============================="
echo " Batch Converter"
echo " Input  : $INPUT"
echo " Output : $OUTPUT"
echo " Target : 22050Hz | mono | 16-bit WAV"
echo "=============================="
echo ""

for FILE in "$INPUT"/*.{wav,mp3,aiff,flac,m4a}; do
  [ -f "$FILE" ] || { SKIP=$((SKIP + 1)); continue; }
  NAME=$(basename "${FILE%.*}")
  OUT="$OUTPUT/${NAME}_22k.wav"

  if [ -f "$OUT" ]; then
    echo "  SKIP (exists): $NAME"
    SKIP=$((SKIP + 1))
    continue
  fi

  ERROR=$(ffmpeg -y -v error \
    -i "$FILE" \
    -ar 22050 -ac 1 -c:a pcm_s16le \
    "$OUT" 2>&1)

  if [ $? -eq 0 ]; then
    echo "  OK: $NAME"
    OK=$((OK + 1))
  else
    echo "  FAIL: $NAME — $ERROR"
    FAIL=$((FAIL + 1))
  fi
done

echo ""
echo "=============================="
echo " RESULT"
echo " OK   : $OK"
echo " FAIL : $FAIL"
echo " SKIP : $SKIP"
echo "=============================="
