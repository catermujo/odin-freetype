#!/usr/bin/env bash

set -e

[ -d freetype ] || git clone --recurse-submodules https://github.com/freetype/freetype --depth=1

echo "Building freetype.."
cd freetype
cmake -S . -B build \
    -DFT_DISABLE_ZLIB=FALSE \
    -DFT_DISABLE_PNG=FALSE \
    -DFT_DISABLE_HARFBUZZ=FALSE \
    -DFT_REQUIRE_BROTLI=FALSE \
    -DCMAKE_BUILD_TYPE=Release

# -DFT_DISABLE_BZIP2=FALSE \

make -C build -j$CPU
if [ $(uname -s) = 'Darwin' ]; then
    make -j$(sysctl -n hw.ncpu)
    LIB_EXT=darwin
else
    make -j$(nproc)
    LIB_EXT=linux
fi

cp objs/.libs/libfreetype.a ../freetype.$LIB_EXT.a
