@echo off

setlocal EnableDelayedExpansion

set "VENDOR_WINDOWS_ARCH=%VSCMD_ARG_TGT_ARCH%"
if not defined VENDOR_WINDOWS_ARCH set "VENDOR_WINDOWS_ARCH=%PROCESSOR_ARCHITECTURE%"
if /I "%VENDOR_WINDOWS_ARCH%"=="AMD64" set "VENDOR_WINDOWS_ARCH=x64"
if /I "%VENDOR_WINDOWS_ARCH%"=="ARM64" set "VENDOR_WINDOWS_ARCH=arm64"
if /I "%VENDOR_WINDOWS_ARCH%"=="X86" set "VENDOR_WINDOWS_ARCH=x64"

set vendor_dir=freetype
set build_dir=build_static
set output_dir=windows_%VENDOR_WINDOWS_ARCH%

if not exist %vendor_dir% (
    git clone --recurse-submodules --revision 23b6cd27ff19b70cbf98e058cd2cf0647d5284ff https://github.com/freetype/freetype --depth=1 %vendor_dir%
)
pushd %vendor_dir%

echo Configuring build...
cmake -S . -B %build_dir% -A %VENDOR_WINDOWS_ARCH% -DFT_DISABLE_ZLIB=TRUE -DFT_DISABLE_PNG=TRUE -DFT_DISABLE_HARFBUZZ=TRUE -DFT_DISABLE_ZLIB=TRUE -DFT_DISABLE_BROTLI=TRUE -DFT_DISABLE_GZIP=TRUE -DCMAKE_BUILD_TYPE=Release -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
REM make setup visualc

echo Building project...
cmake --build %build_dir% -j%NUMBER_OF_PROCESSORS% --config Release

if not exist ..\%output_dir% mkdir ..\%output_dir%
copy /y %build_dir%\Release\freetype.lib ..\%output_dir%\freetype_static.lib

echo Build completed successfully!
popd
