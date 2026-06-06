@echo off

setlocal EnableDelayedExpansion

set "VENDOR_WINDOWS_ARCH=%VSCMD_ARG_TGT_ARCH%"
if not defined VENDOR_WINDOWS_ARCH set "VENDOR_WINDOWS_ARCH=%PROCESSOR_ARCHITECTURE%"
if /I "%VENDOR_WINDOWS_ARCH%"=="AMD64" set "VENDOR_WINDOWS_ARCH=x64"
if /I "%VENDOR_WINDOWS_ARCH%"=="ARM64" set "VENDOR_WINDOWS_ARCH=arm64"
if /I "%VENDOR_WINDOWS_ARCH%"=="X86" set "VENDOR_WINDOWS_ARCH=x64"

set vendor_dir=freetype
set binaries_dir=build\Release
set output_dir=windows_%VENDOR_WINDOWS_ARCH%

if not exist %vendor_dir% (
    git clone --recurse-submodules --revision 23b6cd27ff19b70cbf98e058cd2cf0647d5284ff https://github.com/freetype/freetype --depth=1 %vendor_dir%
)
pushd %vendor_dir%

echo Configuring build...
cmake -S . -B build -A %VENDOR_WINDOWS_ARCH% -DFT_DISABLE_ZLIB=FALSE -DFT_DISABLE_PNG=FALSE -DFT_DISABLE_HARFBUZZ=FALSE -DFT_REQUIRE_BROTLI=FALSE -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release
REM make setup visualc

echo Building project...
cmake --build build -j%NUMBER_OF_PROCESSORS% --config Release

if not exist ..\%output_dir% mkdir ..\%output_dir%
copy /y %binaries_dir%\freetype.dll ..\%output_dir%\
copy /y %binaries_dir%\freetype.lib ..\%output_dir%\

echo Build completed successfully!
popd
