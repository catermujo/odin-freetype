@echo off

setlocal EnableDelayedExpansion

set vendor_dir=freetype
set binaries_dir=build\Release

if not exist %vendor_dir%\NUL (
    git clone --recurse-submodules https://github.com/freetype/freetype --depth=1 %vendor_dir%
)
pushd %vendor_dir%

echo Configuring build...
cmake -S . -B build -DFT_DISABLE_ZLIB=FALSE -DFT_DISABLE_PNG=FALSE -DFT_DISABLE_HARFBUZZ=FALSE -DFT_REQUIRE_BROTLI=FALSE -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release
REM make setup visualc

echo Building project...
cmake --build build -j%NUMBER_OF_PROCESSORS% --config Release

copy /y %binaries_dir%\freetype.dll ..\
copy /y %binaries_dir%\freetype.lib ..\

echo Build completed successfully!
popd
