@echo off

setlocal EnableDelayedExpansion

set vendor_dir=freetype
set build_dir=build_static

if not exist %vendor_dir% (
    git clone --recurse-submodules --revision 23b6cd27ff19b70cbf98e058cd2cf0647d5284ff https://github.com/freetype/freetype --depth=1 %vendor_dir%
)
pushd %vendor_dir%

echo Configuring build...
cmake -S . -B %build_dir% -DFT_DISABLE_ZLIB=TRUE -DFT_DISABLE_PNG=TRUE -DFT_DISABLE_HARFBUZZ=TRUE -DFT_DISABLE_ZLIB=TRUE -DFT_DISABLE_BROTLI=TRUE -DFT_DISABLE_GZIP=TRUE -DCMAKE_BUILD_TYPE=Release -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
REM make setup visualc

echo Building project...
cmake --build %build_dir% -j%NUMBER_OF_PROCESSORS% --config Release

copy /y %build_dir%\Release\freetype.lib ..\freetype_static.lib

echo Build completed successfully!
popd
