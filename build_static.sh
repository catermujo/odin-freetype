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
./autogen.sh
./configure --enable-shared=no --enable-year2038 --without-png --without-harfbuzz --without-bzip2 --without-brotli --without-gzip --with-zlib=no #--with-png=yes --with-harfbuzz=yes --with-librsvg=yes --with-brotli=yes # --with-bzip2=no

if [ $(uname -s) = 'Darwin' ]; then
    CPU=$(sysctl -n hw.ncpu)
    LIB_EXT=darwin
else
    CPU=$(nproc)
    ARCH_DIR=$(linux_arch_dir)
fi
# cmake -S . -B build \
#     -DFT_REQUIRE_ZLIB=TRUE \
#     -DFT_REQUIRE_PNG=TRUE \
#     -DFT_REQUIRE_HARFBUZZ=TRUE \
#     -DFT_REQUIRE_BROTLI=FALSE \
#     -DCMAKE_BUILD_TYPE=Release
# -DFT_DISABLE_ZLIB=TRUE \
# -DFT_DISABLE_PNG=TRUE \
# -DFT_DISABLE_HARFBUZZ=TRUE \

# -DFT_DISABLE_BZIP2=FALSE \

make -j$CPU

if [ $(uname -s) = 'Darwin' ]; then
    cp objs/.libs/libfreetype.a ../freetype.$LIB_EXT.a
else
    mkdir -p "../$ARCH_DIR"
    cp objs/.libs/libfreetype.a "../$ARCH_DIR/freetype.linux.a"
fi
