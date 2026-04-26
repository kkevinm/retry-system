@echo off
setlocal EnableDelayedExpansion

set "temp_dir=.\temp"
set "uber_url=https://dl.smwcentral.net/39036/"
set "uber_dir=.\uber"
set "retry_src=..\src"
set "retry_install=..\retry_install.bat"
set "uber_list=test_uberasmtool_list.txt"

if not exist "%temp_dir%" (
    mkdir "%temp_dir%"
)

if exist "%temp_dir%\%uber_dir%.zip" (
    rm "%temp_dir%\%uber_dir%.zip"
)

if exist "%temp_dir%\%uber_dir%" (
    rmdir /s /q "%temp_dir%\%uber_dir%"
)

cd "%temp_dir%"

:: Create the test rom
powershell "..\create_test_rom.ps1"

:: Download UberASM Tool
echo Downloading "%uber_url%"...

powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%uber_url%', '%uber_dir%.zip')"

if %errorlevel% neq 0 (
    echo Download failed
    goto :End
)

echo Download succeeded
echo.

:: Unzip UberASM Tool
echo Unzipping in "%uber_dir%"...

powershell -Command "Expand-Archive -Path '%uber_dir%.zip' -DestinationPath '%uber_dir%' -Force"

if %errorlevel% neq 0 (
    echo Unzip failed
    goto :End
)

echo Unzip succeeded

:: Install Retry
echo "%uber_dir%\n..\%retry_src%" | call "..\%retry_install%" "%uber_dir%" "..\%retry_src%"

:: Insert Retry
echo Inserting Retry...

".\%uber_dir%\UberASMTool.exe" -p "..\..\%uber_list%" "..\test.smc"

echo.

if %errorlevel% neq 0 (
    echo Retry insertion failed
    goto :End
)

echo Retry insertion succeeded

:End
cd ..
exit /b %errorlevel%
