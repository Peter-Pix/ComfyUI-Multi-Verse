@echo off
echo ========================================
echo    RTX 5090 Compatibility Check
echo ========================================
echo.

echo Checking NVIDIA Driver...
nvidia-smi

echo.
echo Checking CUDA Version...
nvcc --version >nul 2>&1
if %ERRORLEVEL% equ 0 (
    nvcc --version
) else (
    echo CUDA Toolkit not found in PATH
)

echo.
echo Checking PyTorch Installation...
python -c "
import torch
print('PyTorch version:', torch.__version__)
print('CUDA available:', torch.cuda.is_available())
if torch.cuda.is_available():
    print('CUDA version:', torch.version.cuda)
    print('GPU device:', torch.cuda.get_device_name(0))
    print('Compute capability:', torch.cuda.get_device_capability(0))
    
    # Check if compute capability 12.0 (RTX 5090) is supported
    major, minor = torch.cuda.get_device_capability(0)
    if major >= 12:
        print('✓ RTX 5090 (sm_120) fully supported!')
    else:
        print('⚠ GPU detected but may not be RTX 5090')
else:
    print('✗ CUDA not available')
    
print('\nEnvironment variables:')
import os
cuda_arch = os.environ.get('TORCH_CUDA_ARCH_LIST', 'Not set')
print('TORCH_CUDA_ARCH_LIST:', cuda_arch)
"

echo.
echo If you see issues:
echo 1. Update NVIDIA drivers to support CUDA 12.8+
echo 2. Reinstall PyTorch with: pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
echo 3. Set TORCH_CUDA_ARCH_LIST=12.0 if building from source
echo.

pause