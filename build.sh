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
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release

# -DFT_DISABLE_BZIP2=FALSE \

make -C build -j$CPU
if [ $(uname -s) = 'Darwin' ]; then
    make -j$(sysctl -n hw.ncpu)
    LIB_EXT=dylib
else
    make -j$(nproc)
    LIB_EXT=so
fi

cp build/*.$LIB_EXT ../
