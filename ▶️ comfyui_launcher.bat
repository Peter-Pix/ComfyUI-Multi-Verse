@echo off
setlocal EnableDelayedExpansion

title ComfyUI Master Launcher - RTX 5090 Optimized
color 0A

echo.
echo ========================================
echo      ComfyUI Master Launcher
echo       RTX 5090 Optimized
echo ========================================
echo.

REM Define installation directories - FIXED PATH CONSTRUCTION
set BASE_DIR=%~dp0
set MODELS_DIR=C:\Users\rick\ComfyUI\models

REM Remove trailing backslash if present
if "%BASE_DIR:~-1%"=="\" set BASE_DIR=%BASE_DIR:~0,-1%

echo Scanning for ComfyUI installations in: %BASE_DIR%
echo.

REM Check available installations
set COUNT=0
set OPTION[1]=
set OPTION[2]=
set OPTION[3]=
set OPTION[4]=
set OPTION[5]=
set OPTION[6]=

REM Check for standard installations
if exist "comfyui_main" (
    set /a COUNT+=1
    set "OPTION[!COUNT!]=comfyui_main"
    set "DESC[!COUNT!]=Main Stable Version"
    set "PORT[!COUNT!]=8188"
)

if exist "comfyui_experimental" (
    set /a COUNT+=1
    set "OPTION[!COUNT!]=comfyui_experimental" 
    set "DESC[!COUNT!]=Experimental Version"
    set "PORT[!COUNT!]=8189"
)

if exist "comfyui_training" (
    set /a COUNT+=1
    set "OPTION[!COUNT!]=comfyui_training"
    set "DESC[!COUNT!]=Training Version"
    set "PORT[!COUNT!]=8190"
)

REM Check for custom installations - FIXED DIRECTORY CHECK
for /d %%i in (comfyui_*) do (
    set "dir_name=%%i"
    if /i not "!dir_name!"=="comfyui_main" (
        if /i not "!dir_name!"=="comfyui_experimental" (
            if /i not "!dir_name!"=="comfyui_training" (
                set /a COUNT+=1
                set "OPTION[!COUNT!]=%%i"
                set "DESC[!COUNT!]=Custom: %%i"
                set /a "PORT[!COUNT!]=8187 + !COUNT!"
            )
        )
    )
)

if !COUNT! equ 0 (
    echo No ComfyUI installations found!
    echo.
    echo Run create_comfyui_env.bat first to create installations.
    pause
    exit /b 1
)

echo Available ComfyUI Installations:
echo.
for /l %%i in (1,1,!COUNT!) do (
    echo %%i. !DESC[%%i]! (Port: !PORT[%%i]!)
)
echo.
echo M. Manage Installations (Create/Update)
echo Q. Quit
echo.

set /p CHOICE="Select option (1-!COUNT!, M, Q): "

if /i "!CHOICE!"=="Q" exit /b 0
if /i "!CHOICE!"=="M" goto MANAGEMENT

REM Validate numeric choice
set /a NUMCHOICE=!CHOICE! 2>nul
if !NUMCHOICE! lss 1 (
    echo Invalid selection!
    pause
    exit /b 1
)
if !NUMCHOICE! gtr !COUNT! (
    echo Invalid selection!
    pause
    exit /b 1
)

set SELECTED=!OPTION[%CHOICE%]!
set PROJECT_DIR=%BASE_DIR%\!SELECTED!
set VENV_DIR=!PROJECT_DIR!\venv
set COMFYUI_DIR=!PROJECT_DIR!\ComfyUI
set SELECTED_PORT=!PORT[%CHOICE%]!

echo.
echo ========================================
echo Starting: !DESC[%CHOICE%]!
echo Location: !PROJECT_DIR!
echo Port: !SELECTED_PORT!
echo ========================================
echo.

REM Verify installation exists - IMPROVED ERROR CHECKING
if not exist "!PROJECT_DIR!" (
    echo ERROR: Installation directory not found!
    echo Expected: !PROJECT_DIR!
    echo.
    echo Available directories in %BASE_DIR%:
    for /d %%i in (comfyui_*) do echo   - %%i
    echo.
    pause
    exit /b 1
)

if not exist "!VENV_DIR!\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found in:
    echo !VENV_DIR!
    echo.
    echo Recreate this installation using create_comfyui_env.bat
    pause
    exit /b 1
)

if not exist "!COMFYUI_DIR!\main.py" (
    echo ERROR: ComfyUI not found in:
    echo !COMFYUI_DIR!
    echo.
    echo Recreate this installation using create_comfyui_env.bat
    pause
    exit /b 1
)

REM Set RTX 5090 optimization environment variables
set PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
set NVIDIA_TF32_OVERRIDE=1

echo Verifying installation...
call "!VENV_DIR!\Scripts\activate.bat"
python -c "
import torch
import sys
print('Python: ' + sys.executable)
print('PyTorch: ' + torch.__version__)
print('CUDA: ' + ('Available' if torch.cuda.is_available() else 'UNAVAILABLE'))
if torch.cuda.is_available():
    print('GPU: ' + torch.cuda.get_device_name(0))
    print('CUDA Version: ' + torch.version.cuda)
else:
    print('WARNING: Running on CPU only - check NVIDIA drivers')
"

echo.
echo Starting ComfyUI on port !SELECTED_PORT!...
echo.

REM Launch ComfyUI with optimized settings
cd /d "!COMFYUI_DIR!"
python main.py --listen 127.0.0.1 --port !SELECTED_PORT! --highvram

pause
exit /b 0

:MANAGEMENT
echo.
echo ========================================
echo      ComfyUI Installation Manager
echo ========================================
echo.
echo 1. Create New Installation
echo 2. Update Existing Installation
echo 3. Verify Installation Health
echo 4. Back to Main Menu
echo.

set /p MGMT_CHOICE="Select option: "

if "!MGMT_CHOICE!"=="1" (
    if exist "create_comfyui_env.bat" (
        call create_comfyui_env.bat
    ) else (
        echo create_comfyui_env.bat not found in current directory!
        pause
    )
    goto :EOF
) else if "!MGMT_CHOICE!"=="2" (
    if exist "update_comfyui_installations.bat" (
        call update_comfyui_installations.bat
    ) else (
        echo update_comfyui_installations.bat not found!
        pause
    )
    goto :EOF
) else if "!MGMT_CHOICE!"=="3" (
    if exist "verify_installations.bat" (
        call verify_installations.bat
    ) else (
        echo verify_installations.bat not found!
        pause
    )
    goto :EOF
) else if "!MGMT_CHOICE!"=="4" (
    goto :EOF
) else (
    echo Invalid selection!
    pause
    goto :EOF
)