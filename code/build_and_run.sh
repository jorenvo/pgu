#!/usr/bin/env bash

# no -e because the assembler programs return result with return code
set -uo pipefail

NAME="${1}"
as --32 "${NAME}" -o out.o
ld -m elf_i386 out.o

./a.out
echo $?
