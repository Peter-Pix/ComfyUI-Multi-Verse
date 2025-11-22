@echo off
setlocal EnableDelayedExpansion

echo.
echo ========================================
echo      Verifying ComfyUI Installations
echo ========================================
echo.

set COUNT=0
for /d %%i in (comfyui_*) do (
    set /a COUNT+=1
    echo.
    echo Checking: %%i
    
    if exist "%%i\venv\Scripts\activate.bat" (
        echo ✓ Virtual Environment: OK
    ) else (
        echo ✗ Virtual Environment: MISSING
    )
    
    if exist "%%i\ComfyUI\main.py" (
        echo ✓ ComfyUI: OK
    ) else (
        echo ✗ ComfyUI: MISSING
    )
    
    if exist "%%i\ComfyUI\models" (
        echo ✓ Local Models: OK
    ) else (
        echo ℹ Local Models: Using shared directory
    )
    
    REM Test GPU detection
    if exist "%%i\venv\Scripts\activate.bat" (
        call "%%i\venv\Scripts\activate.bat"
        python -c "import torch; print(f'  GPU Detection: {\\\"OK\\\" if torch.cuda.is_available() else \\\"FAILED\\\"}')" 2>nul
        if errorlevel 1 echo "  GPU Detection: PYTHON ERROR"
        call deactivate
    )
)

if !COUNT! equ 0 (
    echo No ComfyUI installations found!
)

echo.
pause