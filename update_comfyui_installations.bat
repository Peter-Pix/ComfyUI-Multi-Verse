@echo off
setlocal EnableDelayedExpansion

echo.
echo ========================================
echo      Updating ComfyUI Installations
echo ========================================
echo.

for /d %%i in (comfyui_*) do (
    if exist "%%i\ComfyUI" (
        echo.
        echo Updating: %%i
        cd "%%i\ComfyUI"
        
        echo Pulling latest changes...
        git pull
        
        echo Updating dependencies...
        call "..\venv\Scripts\activate.bat"
        pip install -r requirements.txt --upgrade
        
        cd ..\..
        echo ✓ Updated %%i
    )
)

echo.
echo All installations updated!
pause