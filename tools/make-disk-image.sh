#!/usr/bin/env bash

set -e

build_dir=$1
image_name=$2

echo "Making disk image..."
dd of="$build_dir"/"$image_name" if=/dev/zero bs=1M count=128

echo "Copying the bootloader..."
dd of="$build_dir"/"$image_name" if="$build_dir"/loader/mbr.bin seek=0 conv=notrunc
