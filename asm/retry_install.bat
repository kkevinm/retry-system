@echo off
SetLocal EnableDelayedExpansion

set /p uber_folder="UberASM Tool folder where to install: "
set retry_folder="."

echo.

if exist "gamemode" if exist "library" if exist "retry_config" (
    goto :retry_exist
)

set /p retry_folder="Retry asm folder to install: "

if not exist "!retry_folder!" (
    echo Error: !retry_folder! does not exist^^!
    goto :end
)

if exist "!retry_folder!\gamemode" if exist "!retry_folder!\library" if exist "!retry_folder!\retry_config" (
    goto :retry_exist
)

echo Error: !retry_folder! is not a Retry asm folder^^!
goto :end

:retry_exist

set backup_folder=retry_old_backup

if not exist "!uber_folder!" (
    echo Error: !uber_folder! does not exist^^!
    goto :end
)

if exist "!uber_folder!\gamemode" if exist "!uber_folder!\library" if exist "!uber_folder!\list.txt" (
    goto :ok
)
echo Error: !uber_folder! is not a UberASM Tool folder^^!
goto :end

:ok

if exist "!uber_folder!\gamemode\retry_gm*.asm" (
    goto :backup_old
)
if exist "!uber_folder!\library\retry.asm" (
    goto :backup_old
)
if exist "!uber_folder!\retry_config" (
    goto :backup_old
)

:install

echo.
echo Installing Retry...

copy "!retry_folder!\gamemode\retry_gm*.asm" "!uber_folder!\gamemode" > nul
copy "!retry_folder!\library\retry.asm" "!uber_folder!\library" > nul
mkdir "!uber_folder!\retry_config" > nul
xcopy /e /v "!retry_folder!\retry_config" "!uber_folder!\retry_config" > nul

echo.
echo Retry files copied successfully^^!

echo.
echo To complete the installation, copy these lines in your "list.txt" under gamemode:
echo.
echo     00 retry_gm00.asm
echo     06 retry_gm06.asm
echo     07 retry_gm07.asm
echo     0C retry_gm0C.asm
echo     0D retry_gm0D.asm
echo     0F retry_gm0F.asm
echo     10 retry_gm10.asm
echo     11 retry_gm11.asm
echo     12 retry_gm12.asm
echo     13 retry_gm13.asm
echo     14 retry_gm14.asm
echo     15 retry_gm15.asm
echo     16 retry_gm16.asm
echo     19 retry_gm19.asm

goto :end

:backup_old

echo Previous Retry installation found. Backing up old version...

if exist "!uber_folder!\!backup_folder!" (
    echo.
    echo Warning: old Retry backup found^^!
    echo If you wish to continue the installation, the old backup will be removed and replaced with the current Retry backup.
    set /p delete_backup_confirm="Continue? [y/n] "
    
    if "!delete_backup_confirm!"=="y" (
        goto :remove_old
    )
    if "!delete_backup_confirm!"=="Y" (
        goto :remove_old
    )
    echo.
    echo Installation aborted.
    goto :end

    :remove_old
    rmdir /s /q "!uber_folder!\!backup_folder!" > nul
    
    echo.
    echo Old backup deleted successfully
)

mkdir "!uber_folder!\!backup_folder!" > nul

if exist "!uber_folder!\gamemode\retry_gm*.asm" (
    mkdir "!uber_folder!\!backup_folder!\gamemode" > nul
    copy "!uber_folder!\gamemode\retry_gm*.asm" "!uber_folder!\!backup_folder!\gamemode" > nul
    del "!uber_folder!\gamemode\retry_gm*.asm" > nul
)

if exist "!uber_folder!\library\retry.asm" (
    mkdir "!uber_folder!\!backup_folder!\library" > nul
    copy "!uber_folder!\library\retry.asm" "!uber_folder!\!backup_folder!\library" > nul
    del "!uber_folder!\library\retry.asm" > nul
)

if exist "!uber_folder!\retry_config" (
    mkdir "!uber_folder!\!backup_folder!\retry_config" > nul
    xcopy /e /v "!uber_folder!\retry_config" "!uber_folder!\!backup_folder!\retry_config" > nul
    rmdir /s /q "!uber_folder!\retry_config" > nul
)

echo.
echo Previous version backed up at !uber_folder!\!backup_folder!

goto :install

:end

echo.

pause
