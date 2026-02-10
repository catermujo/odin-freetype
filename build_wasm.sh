#!/usr/bin/env bash

set -e

if [ $(uname -s) = 'Darwin' ]; then
    CPU=$(sysctl -n hw.ncpu)
else
    CPU=$(nproc)
fi

WASM_THREAD_FLAGS=${WASM_THREAD_FLAGS:-"-pthread -matomics -mbulk-memory"}

# [ -d brotli ] || git clone --recurse-submodules https://github.com/google/brotli.git --depth=1

# cd brotli

# emcmake cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBROTLI_EMSCRIPTEN=TRUE
# emmake make -C build -j$CPU

# cd ..

[ -d freetype ] || git clone --recurse-submodules https://github.com/freetype/freetype --depth=1

cd freetype
# -DBROTLIDEC_LIBRARIES="../brotli/build/libbrotlidec.a" \

# TODO: better flags
emcmake cmake -S . -B build \
    -DFT_DISABLE_ZLIB=FALSE \
    -DFT_DISABLE_PNG=FALSE \
    -DFT_DISABLE_HARFBUZZ=FALSE \
    -DFT_REQUIRE_BROTLI=FALSE \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="$WASM_THREAD_FLAGS" \
    -DCMAKE_CXX_FLAGS="$WASM_THREAD_FLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS="$WASM_THREAD_FLAGS" \
    -DCMAKE_SHARED_LINKER_FLAGS="$WASM_THREAD_FLAGS" \
    -DCMAKE_MODULE_LINKER_FLAGS="$WASM_THREAD_FLAGS"
# -DFT_DISABLE_BZIP2=FALSE \

emmake make -C build -j$CPU

cp build/libfreetype.a ../freetype.wasm.a
