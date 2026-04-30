#!/bin/bash
set -e

if [ $# -lt 1 ]; then
    echo "usage: $0 ELF_FILE"
    exit 1
fi

elf_in=$1
uf2_out=${elf_in/.elf/.uf2}

picotool uf2 convert ${elf_in} -t elf ${uf2_out} -t uf2

echo "Output: ${uf2_out}"
