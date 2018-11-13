#!/usr/bin/env bash
set -euo pipefail

# apply EXIF rotation set by phone
for PHOTO in "$@"
do
    convert "${PHOTO}" -auto-orient "${PHOTO}"
done

noteshrink -wo notes.pdf "$@"
rm -v ./*.png
