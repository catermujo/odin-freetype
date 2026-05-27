#!/usr/bin/env bash

set -e

clone_at_revision() {
    local dir="$1"
    local revision="$2"
    local remote="$3"
    shift 3
    [ -d "$dir" ] && return
    git clone "$@" "$remote" "$dir"
    if ! git -C "$dir" checkout --detach "$revision"; then
        git -C "$dir" fetch origin "$revision"
        git -C "$dir" checkout --detach FETCH_HEAD
    fi
    if [ -f "$dir/.gitmodules" ]; then
        git -C "$dir" submodule update --init --recursive
    fi
}

clone_at_revision freetype 23b6cd27ff19b70cbf98e058cd2cf0647d5284ff https://github.com/freetype/freetype --recurse-submodules --depth=1

linux_arch_dir() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "linux_x64" ;;
        aarch64 | arm64) echo "linux_arm64" ;;
        *) echo "linux_$(uname -m)" ;;
    esac
}

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

if [ $(uname -s) = 'Darwin' ]; then
    CPU=$(sysctl -n hw.ncpu)
    LIB_EXT=dylib
else
    CPU=$(nproc)
    LIB_EXT=so
fi
make -C build -j$CPU

if [ $(uname -s) = 'Darwin' ]; then
    # DUMBAI: Stage only ABI-major FreeType dylibs to avoid duplicate unversioned and patch-level alias files in vendor output.
    cp build/libfreetyped.6.dylib ../
    cp build/libfreetype.6.dylib ../
else
    ARCH_DIR=$(linux_arch_dir)
    mkdir -p "../$ARCH_DIR"
    cp build/*.$LIB_EXT "../$ARCH_DIR"/
fi
