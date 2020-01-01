#!/usr/bin/env bash
set -uo pipefail

FILENAME="${1}"
as "${FILENAME}" -o out.o
ld -macosx_version_min 10.13 -lSystem out.o -e _main -o out     # -e specify the entry point of the executable
./out
echo $? # show last return code, should show 0
