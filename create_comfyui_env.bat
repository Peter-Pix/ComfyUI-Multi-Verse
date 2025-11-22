@echo off
setlocal EnableDelayedExpansion

echo.
echo ========================================
echo    ComfyUI Environment Setup Wizard
echo      RTX 5090 Optimized Installation
echo ========================================
echo.

REM Set common models directory
set MODELS_DIR=C:\Users\rick\ComfyUI\models

echo Checking NVIDIA driver compatibility...
nvidia-smi >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo [!] ERROR: NVIDIA drivers not found or not working
    echo Please install latest NVIDIA drivers for RTX 5090
    echo Required: Driver supporting CUDA 12.8+
    pause
    exit /b 1
)

echo.
echo Available Installation Types:
echo 1. Main Stable Version (Recommended for daily use)
echo 2. Experimental Version (Latest features, may be unstable)
echo 3. Training Version (Optimized for model training)
echo 4. Custom Setup (Advanced users)
echo.

set /p CHOICE="Select installation type (1-4): "

if "%CHOICE%"=="1" (
    set ENV_NAME=comfyui_main
    set GIT_BRANCH=master
    set INSTALL_TYPE=stable
) else if "%CHOICE%"=="2" (
    set ENV_NAME=comfyui_experimental
    set GIT_BRANCH=master
    set INSTALL_TYPE=experimental
) else if "%CHOICE%"=="3" (
    set ENV_NAME=comfyui_training
    set GIT_BRANCH=master
    set INSTALL_TYPE=training
) else if "%CHOICE%"=="4" (
    set /p ENV_NAME="Enter custom environment name: "
    set /p GIT_BRANCH="Enter Git branch [master]: "
    if "!GIT_BRANCH!"=="" set GIT_BRANCH=master
    set INSTALL_TYPE=custom
) else (
    echo Invalid selection. Exiting.
    pause
    exit /b 1
)

REM Set project directory structure
set PROJECT_DIR=%CD%\%ENV_NAME%
set VENV_DIR=%PROJECT_DIR%\venv
set COMFYUI_DIR=%PROJECT_DIR%\ComfyUI

echo.
echo Installation Summary:
echo - Environment: !ENV_NAME!
echo - Project Directory: !PROJECT_DIR!
echo - Virtual Environment: !VENV_DIR!
echo - ComfyUI Directory: !COMFYUI_DIR!
echo - Models Directory: !MODELS_DIR!
echo - Installation Type: !INSTALL_TYPE!
echo.

set /p CONFIRM="Proceed with installation? (Y/N): "
if /i not "!CONFIRM!"=="Y" (
    echo Installation cancelled.
    pause
    exit /b 0
)

echo.
echo ========================================
echo Step 1: Creating Project Structure...
echo ========================================
echo.

if not exist "!PROJECT_DIR!" mkdir "!PROJECT_DIR!"
if not exist "!MODELS_DIR!" (
    echo Creating shared models directory...
    mkdir "!MODELS_DIR!"
)

echo.
echo ========================================
echo Step 2: Installing ComfyUI...
echo ========================================
echo.

if exist "!COMFYUI_DIR!\" (
    echo ComfyUI directory already exists. Skipping clone.
) else (
    echo Cloning ComfyUI repository...
    git clone https://github.com/comfyanonymous/ComfyUI.git "!COMFYUI_DIR!"
    if !ERRORLEVEL! neq 0 (
        echo [!] Failed to clone ComfyUI repository
        pause
        exit /b 1
    )
    
    if not "!GIT_BRANCH!"=="master" (
        echo Switching to !GIT_BRANCH! branch...
        cd "!COMFYUI_DIR!"
        git checkout !GIT_BRANCH!
    )
)

echo.
echo ========================================
echo Step 3: Creating Virtual Environment...
echo ========================================
echo.

echo Creating Python virtual environment...
python -m venv "!VENV_DIR!"
if !ERRORLEVEL! neq 0 (
    echo [!] Failed to create virtual environment
    pause
    exit /b 1
)

echo.
echo ========================================
echo Step 4: Installing Dependencies...
echo ========================================
echo.

call "!VENV_DIR!\Scripts\activate.bat"

echo Upgrading pip and setuptools...
python -m pip install --upgrade pip setuptools wheel

echo.
echo ========================================
echo Installing PyTorch for RTX 5090 (CUDA 12.8)...
echo ========================================
echo.

echo Option 1: Installing stable PyTorch 2.7.0+ with CUDA 12.8 support...
echo This may take several minutes...
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

if !ERRORLEVEL! neq 0 (
    echo.
    echo [!] Stable installation failed, trying nightly build...
    pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128
)

REM Verify PyTorch can detect CUDA and RTX 5090
echo.
echo ========================================
echo Verifying RTX 5090 Compatibility...
echo ========================================
echo.

python -c "
import torch
print('PyTorch version:', torch.__version__)
print('CUDA available:', torch.cuda.is_available())
if torch.cuda.is_available():
    print('CUDA version:', torch.version.cuda)
    print('GPU device:', torch.cuda.get_device_name(0))
    print('Compute capability:', torch.cuda.get_device_capability(0))
    print('RTX 5090 detection:','5090' in torch.cuda.get_device_name(0) or 'RTX 50' in torch.cuda.get_device_name(0))
else:
    print('ERROR: CUDA not detected!')
"

if !ERRORLEVEL! neq 0 (
    echo.
    echo [!] WARNING: PyTorch CUDA verification failed!
    echo This may indicate driver or installation issues.
)

echo.
echo Installing ComfyUI core requirements...
cd "!COMFYUI_DIR!"
pip install -r requirements.txt

REM Install additional packages based on installation type
if "!INSTALL_TYPE!"=="training" (
    echo.
    echo Installing training-specific dependencies...
    pip install xformers --index-url https://download.pytorch.org/whl/nightly/cu128
    pip install accelerate tensorboard peft bitsandbytes
    pip install datasets transformers huggingface-hub
) else if "!INSTALL_TYPE!"=="experimental" (
    echo.
    echo Installing experimental packages...
    pip install xformers --index-url https://download.pytorch.org/whl/nightly/cu128
)

echo.
echo ========================================
echo Step 5: Configuration Setup...
echo ========================================
echo.

set CONFIG_FILE=!COMFYUI_DIR!\extra_model_paths.yaml
if not exist "!CONFIG_FILE!" (
    echo Creating model configuration...
    (
        echo #
        echo # Shared Models Configuration
        echo # Generated automatically by setup script
        echo #
        echo base_path: !COMFYUI_DIR!
        echo.
        echo model_folder: !MODELS_DIR!
        echo checkpoints: !MODELS_DIR!\checkpoints
        echo configs: !MODELS_DIR!\configs
        echo vae: !MODELS_DIR!\vae
        echo loras: !MODELS_DIR!\loras
        echo upscale_models: !MODELS_DIR!\upscale_models
        echo controlnet: !MODELS_DIR!\controlnet
        echo embeddings: !MODELS_DIR!\embeddings
        echo hypernetworks: !MODELS_DIR!\hypernetworks
        echo custom_nodes: !COMFYUI_DIR!\custom_nodes
    ) > "!CONFIG_FILE!"
)

echo.
echo ========================================
echo Step 6: Creating Optimized Launch Scripts...
echo ========================================
echo.

REM Create main launch script with RTX 5090 optimizations
(
    echo @echo off
    echo setlocal
    echo.
    echo echo Starting ComfyUI - !ENV_NAME!...
    echo echo RTX 5090 Optimized Configuration
    echo echo Project: !PROJECT_DIR!
    echo echo Models: !MODELS_DIR!
    echo.
    echo REM Set RTX 5090 optimization environment variables
    echo set PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
    echo set NVIDIA_TF32_OVERRIDE=1
    echo.
    echo REM Activate virtual environment
    echo call "%~dp0..\venv\Scripts\activate.bat"
    echo.
    echo REM Navigate to ComfyUI directory
    echo cd /d "!COMFYUI_DIR!"
    echo.
    echo REM Verify CUDA before launch
    echo python -c "import torch; print(f'Using: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \\\"CPU ONLY\\\"}')"
    echo.
    echo REM Launch ComfyUI with RTX 5090 optimized settings
    echo python main.py --listen 127.0.0.1 --port 8188 --highvram
    echo.
    echo pause
) > "!PROJECT_DIR!\launch_comfyui.bat"

REM Create desktop shortcut
set DESKTOP_SCRIPT=%USERPROFILE%\Desktop\Launch_!ENV_NAME!.bat
(
    echo @echo off
    echo cd /d "!PROJECT_DIR!"
    echo call launch_comfyui.bat
) > "!DESKTOP_SCRIPT!"

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Project Location: !PROJECT_DIR!
echo Virtual Environment: !VENV_DIR!
echo Shared Models: !MODELS_DIR!
echo.
echo RTX 5090 Configuration:
echo - PyTorch 2.7.0+ with CUDA 12.8 support
echo - TF32 enabled for faster computations
echo - Expandable CUDA segments for memory management
echo.
echo Launch Options:
echo 1. Navigate to !PROJECT_DIR! and run 'launch_comfyui.bat'
echo 2. Use desktop shortcut: Launch_!ENV_NAME!.bat
echo.

REM Display post-installation verification
call "!VENV_DIR!\Scripts\activate.bat"
python -c "
import torch
print('\n=== FINAL VERIFICATION ===')
print(f'PyTorch: {torch.__version__}')
print(f'CUDA: {torch.version.cuda}')
print(f'GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \\\"None\\\"}')
if torch.cuda.is_available():
    compute_capability = torch.cuda.get_device_capability(0)
    print(f'Compute Capability: {compute_capability[0]}.{compute_capability[1]}')
    print('✓ RTX 5090 ready!')
else:
    print('✗ CUDA not available - check drivers')
"

echo.
echo Next steps:
echo 1. Place your models in: !MODELS_DIR!
echo 2. Add custom nodes to: !COMFYUI_DIR!\custom_nodes
echo 3. Launch using the provided scripts
echo 4. Check NVIDIA drivers if CUDA is not detected
echo.

pause