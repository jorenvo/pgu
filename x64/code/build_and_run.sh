#!/usr/bin/env bash
set -euo pipefail

FILENAME="${1}"
as -static "${FILENAME}" -o out.o
ld -static -macosx_version_min 10.13 out.o -e _main -o a.out     # -e specify the entry point of the executable

set +e
./a.out
echo $? # show last return code, should show 0
