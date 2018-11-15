#!/usr/bin/env bash
as --gstabs --32 1_writer.s -o out.o
ld -m elf_i386 out.o
