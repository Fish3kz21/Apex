@echo off
REM Apex AI Pets - Package for Windows 11 (Win64)
REM This script builds, cooks, and packages the game for distribution.

setlocal enabledelayedexpansion

REM Get current directory
set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR%..\
set PROJECT_NAME=ApexAIPets
set PROJECT_FILE=%PROJECT_DIR%%PROJECT_NAME%.uproject

REM Check if UE_ROOT is set
if not defined UE_ROOT (
    echo.
    echo ERROR: UE_ROOT environment variable not set!
    echo Please install Unreal Engine 5.4 or set:
    echo   setx UE_ROOT "C:\Program Files\Epic Games\UE_5.4"
    echo.
    pause
    exit /b 1
)

REM Check if project file exists
if not exist "%PROJECT_FILE%" (
    echo.
    echo ERROR: Project file not found: %PROJECT_FILE%
    echo.
    pause
    exit /b 1
)

echo.
echo ====================================================
echo  Apex AI Pets - Windows11 Win64 Packaging
echo ====================================================
echo.
echo Project: %PROJECT_NAME%
echo Location: %PROJECT_DIR%
echo Unreal Engine: %UE_ROOT%
echo.
pause

REM Clean previous build (optional - comment out to skip)
echo.
echo [1/5] Cleaning previous build artifacts...
if exist "%PROJECT_DIR%Binaries" (
    echo Removing Binaries directory...
    rmdir /s /q "%PROJECT_DIR%Binaries" >nul 2>&1
)
if exist "%PROJECT_DIR%Intermediate" (
    echo Removing Intermediate directory...
    rmdir /s /q "%PROJECT_DIR%Intermediate" >nul 2>&1
)
if exist "%PROJECT_DIR%Saved" (
    echo Removing Saved directory...
    rmdir /s /q "%PROJECT_DIR%Saved" >nul 2>&1
)

REM Generate project files
echo.
echo [2/5] Generating project files...
call "%UE_ROOT%\Engine\Build\BatchFiles\GenerateProjectFiles.bat" "%PROJECT_FILE%" -vs2022 -game
if errorlevel 1 (
    echo ERROR: Failed to generate project files!
    pause
    exit /b 1
)

REM Build editor binaries (required for cooking)
echo.
echo [3/5] Building editor binaries...
call "%UE_ROOT%\Engine\Build\BatchFiles\Build.bat" ^
    -Project="%PROJECT_FILE%" ^
    -Target=%PROJECT_NAME%Editor ^
    -Platform=Win64 ^
    -Configuration=Development ^
    -WaitMutex
if errorlevel 1 (
    echo ERROR: Failed to build editor binaries!
    pause
    exit /b 1
)

REM Main packaging command
echo.
echo [4/5] Building, cooking, and packaging...
echo This may take 5-10 minutes...
echo.

call "%UE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun ^
    -Project="%PROJECT_FILE%" ^
    -TargetPlatforms=Win64 ^
    -ClientConfig=Shipping ^
    -ServerConfig=Shipping ^
    -Build ^
    -Cook ^
    -Package ^
    -Stage ^
    -Archive ^
    -ArchiveDirectory="%PROJECT_DIR%Windows11_Package" ^
    -CreateChunkInstall ^
    -Compressed ^
    -Maps=/Game/Maps/APEX_Startup ^
    -Verbose

if errorlevel 1 (
    echo.
    echo ERROR: Packaging failed!
    echo Check the log output above for details.
    pause
    exit /b 1
)

REM Verify maps were packaged
echo.
echo [5/5] Verifying package contents...
if not exist "%PROJECT_DIR%Windows11_Package\Windows\Content\Maps" (
    echo.
    echo ERROR: Maps directory not found in packaged build!
    echo The game will not run without map data.
    echo.
    pause
    exit /b 1
)

echo.
echo ====================================================
echo  PACKAGING SUCCESSFUL!
echo ====================================================
echo.
echo Maps verified in package:
dir /B "%PROJECT_DIR%Windows11_Package\Windows\Content\Maps\*.umap" 2>nul
echo.
echo Executable location:
echo   %PROJECT_DIR%Windows11_Package\Windows\%PROJECT_NAME%.exe
echo.
echo Package size:
for /f "tokens=5" %%A in ('dir /-C "%PROJECT_DIR%Windows11_Package\Windows\%PROJECT_NAME%.exe"') do echo   %%A bytes
echo.
echo Ready to distribute or test!
echo.
pause
