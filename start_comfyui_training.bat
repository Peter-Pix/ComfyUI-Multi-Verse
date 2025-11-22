@echo off
setlocal

title ComfyUI Training - RTX 5090
color 0B

REM FIXED PATH - use current directory properly
set "PROJECT_DIR=%~dp0comfyui_training"
set VENV_DIR=%PROJECT_DIR%\venv
set COMFYUI_DIR=%PROJECT_DIR%\ComfyUI
set MODELS_DIR=C:\Users\rick\ComfyUI\models

echo.
echo ========================================
echo    Starting ComfyUI Training
echo         RTX 5090 Optimized
echo ========================================
echo.

REM IMPROVED ERROR CHECKING
if not exist "%PROJECT_DIR%" (
    echo ERROR: comfyui_training not found!
    echo.
    echo Current directory: %~dp0
    echo Expected: %PROJECT_DIR%
    echo.
    echo Available directories:
    for /d %%i in ("%~dp0comfyui_*") do echo   - %%~nxi
    echo.
    echo Run create_comfyui_env.bat first.
    pause
    exit /b 1
)

if not exist "%VENV_DIR%\Scripts\activate.bat" (
    echo ERROR: Virtual environment missing!
    echo Recreate using create_comfyui_env.bat
    pause
    exit /b 1
)

echo Project: %PROJECT_DIR%
echo Models: %MODELS_DIR%
echo FEATURES: Training libraries enabled
echo.

set PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
set NVIDIA_TF32_OVERRIDE=1

echo Verifying training packages...
call "%VENV_DIR%\Scripts\activate.bat"
python -c "
import torch
print(f'PyTorch: {torch.__version__}')
print(f'GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \\\"CPU ONLY\\\"}')
try:
    import xformers
    print('xformers: OK')
except:
    print('xformers: MISSING')
try:
    import accelerate
    print('accelerate: OK') 
except:
    print('accelerate: MISSING')
try:
    import peft
    print('PEFT: OK')
except:
    print('PEFT: MISSING')
"

echo.
echo Starting ComfyUI Training Edition...
cd /d "%COMFYUI_DIR%"
python main.py --listen 127.0.0.1 --port 8190 --highvram

pause