#!/usr/bin/env bash
set -euo pipefail

compile () {
    NAME="${1%.s}"

    as --gstabs --32 "${NAME}.s" -o "${NAME}.o"
    ld -m elf_i386 "${NAME}.o" -o "${NAME}"
}

compile '1_writer.s'
compile '2_reader.s'
