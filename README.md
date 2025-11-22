# 🚀 Complete Guide: Multi-Environment ComfyUI Setup with RTX 5090

This guide will help you create and manage multiple isolated ComfyUI environments, perfect for different workflows while sharing models and optimizing for your RTX 5090.

## 📋 Table of Contents
1. [Understanding the Approach](#understanding-the-approach)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [File Structure](#file-structure)
5. [Step-by-Step Setup](#step-by-step-setup)
6. [Managing Environments](#managing-environments)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

## 🎯 Understanding the Approach

### Why Multiple Environments?
- **Dependency Isolation**: Different custom nodes require different package versions
- **Stability**: Experimental features won't break your main installation
- **Specialization**: Optimized environments for specific tasks (training, audio, etc.)
- **Testing**: Try new features without risking your stable setup

### How It Works
```
Base Directory/
├── comfyui_main/          # Stable daily use
├── comfyui_experimental/  # Latest features
├── comfyui_training/      # Model training
├── comfyui_audio/         # Audio-specific nodes
└── Shared Models/         # All installations use the same model files
```

## ⚙️ Prerequisites

### Hardware Requirements
- NVIDIA RTX 5090 (or any CUDA-compatible GPU)
- 16GB+ RAM recommended
- 50GB+ free disk space (for models and environments)

### Software Requirements
- **Windows 10/11** with latest updates
- **Python 3.10-3.11** (recommended for compatibility)
- **Git** installed and in PATH
- **NVIDIA Drivers** supporting CUDA 12.8+

### Verify Your System
Run these commands in Command Prompt:

```cmd
# Check Python
python --version

# Check Git
git --version

# Check NVIDIA
nvidia-smi

# Check CUDA (if installed)
nvcc --version
```

## 🚀 Quick Start

### 1. Download the Setup Files
Create a new folder for your AI projects and save these files:

**`create_comfyui_env.bat`** - Installation wizard
**`comfyui_launcher.bat`** - Master launcher with menu
**`check_installations.bat`** - Diagnostic tool

### 2. Run the Installation
```cmd
# Navigate to your AI projects folder
cd C:\AI_Projects

# Run the installation wizard
create_comfyui_env.bat
```

### 3. Choose Your Installation Type
Select from the menu:
- **1. Main Stable** - Daily use, most stable
- **2. Experimental** - Latest features, may be unstable  
- **3. Training** - Optimized for model training
- **4. Custom** - Advanced users

### 4. Launch ComfyUI
```cmd
# Use the master launcher (recommended)
comfyui_launcher.bat

# Or direct launchers
start_comfyui_main.bat
start_comfyui_experimental.bat
```

## 📁 File Structure

### Recommended Layout
```
C:\AI_Projects\
├── 📜 create_comfyui_env.bat          # Installation wizard
├── 📜 comfyui_launcher.bat            # Master menu launcher
├── 📜 check_installations.bat         # Diagnostic tool
├── 📜 update_comfyui_installations.bat # Batch updater
├── 🔧 comfyui_main\                   # Stable installation
│   ├── 🐍 venv\                       # Virtual environment
│   └── 💻 ComfyUI\                    # ComfyUI files
├── 🔬 comfyui_experimental\           # Testing installation  
│   ├── 🐍 venv\
│   └── 💻 ComfyUI\
├── 🎓 comfyui_training\               # Training installation
│   ├── 🐍 venv\
│   └── 💻 ComfyUI\
└── 🗂️ C:\Users\rick\ComfyUI\models\   # SHARED models directory
    ├── checkpoints\
    ├── loras\
    ├── vae\
    └── controlnet\
```

## 🔧 Step-by-Step Setup

### Step 1: Prepare Your Workspace
```cmd
# Create main AI projects folder
mkdir C:\AI_Projects
cd C:\AI_Projects

# Create shared models directory (if needed)
mkdir C:\Users\rick\ComfyUI\models
```

### Step 2: First Installation (Main Stable)
1. Run `create_comfyui_env.bat`
2. Select **Option 1: Main Stable Version**
3. Wait for installation (10-20 minutes)
4. Verify installation completes successfully

### Step 3: Verify RTX 5090 Detection
After installation, the script will automatically verify:
- ✅ PyTorch with CUDA 12.8+ support
- ✅ RTX 5090 GPU detection
- ✅ Compute capability sm_120
- ✅ All dependencies installed

### Step 4: Additional Installations (Optional)
Repeat the process for other environment types:
- **Experimental** - For testing new features
- **Training** - For LoRA/model training
- **Custom** - For specialized workflows

### Step 5: Organize Your Models
Place your models in the shared directory:
```
C:\Users\rick\ComfyUI\models\
├── checkpoints\      # .safetensors, .ckpt files
├── loras\           # LoRA files
├── vae\             # VAE models
├── controlnet\      # ControlNet models
├── upscale_models\  # ESRGAN, etc.
└── embeddings\      # Textual inversions
```

## 🎮 Managing Environments

### Daily Use - Master Launcher (Recommended)
```cmd
comfyui_launcher.bat
```
**Benefits:**
- Shows all available installations
- Automatic port assignment (no conflicts)
- Health checks before launching
- Management menu for updates

### Quick Access - Individual Launchers
```cmd
start_comfyui_main.bat
start_comfyui_experimental.bat
start_comfyui_training.bat
```

### Running Multiple Instances Simultaneously
Each installation uses different ports:
- **Main**: Port 8188
- **Experimental**: Port 8189  
- **Training**: Port 8190
- **Custom**: Port 8191+

Access them simultaneously:
- `http://127.0.0.1:8188`
- `http://127.0.0.1:8189`
- `http://127.0.0.1:8190`

## 🛠️ Maintenance

### Updating All Installations
```cmd
# From master launcher, choose 'M' then '2'
# Or run directly:
update_comfyui_installations.bat
```

### Checking Installation Health
```cmd
# From master launcher, choose 'M' then '3'  
# Or run directly:
check_installations.bat
```

### Adding Custom Nodes
Custom nodes go in each installation's folder:
```
comfyui_main\ComfyUI\custom_nodes\
comfyui_experimental\ComfyUI\custom_nodes\
```

**Tip**: Install nodes separately in each environment to avoid conflicts.

## 🔧 Troubleshooting

### Common Issues and Solutions

#### ❌ "Installation not found" Error
**Problem**: Launcher can't find the installation directory.

**Solution**:
```cmd
# Run diagnostic
check_installations.bat

# Verify directory exists
dir comfyui_*
```

#### ❌ CUDA Not Detected
**Problem**: PyTorch can't find your RTX 5090.

**Solution**:
1. Update NVIDIA drivers to support CUDA 12.8+
2. Verify installation used correct PyTorch version:
   ```cmd
   pip list | findstr torch
   ```
3. Reinstall with CUDA 12.8 support

#### ❌ Port Already in Use
**Problem**: Another application is using the ComfyUI port.

**Solution**:
- Use different ports for each installation
- Check running processes:
  ```cmd
  netstat -ano | findstr :8188
  ```

#### ❌ Dependency Conflicts
**Problem**: Custom nodes downgrade packages (like huggingface-hub).

**Solution**:
- Use separate environments for conflicting nodes
- Install problematic nodes in experimental environment first

### Diagnostic Commands

```cmd
# Check GPU detection
python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}, GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else None}')"

# Check installation structure
check_installations.bat

# Verify Python environment
where python
pip list | findstr torch
```

## 💡 Best Practices

### 1. Environment Strategy
- **Main**: Stable nodes only, daily workflow
- **Experimental**: New nodes, testing features
- **Training**: Dedicated to model training
- **Audio/Video**: Specialized for media processing

### 2. Model Management
- Keep all models in the shared directory
- Use symbolic links if you have models on different drives
- Regularly clean up unused models to save space

### 3. Backup Strategy
- Export your workflows regularly
- Backup your `ComfyUI\user` folder for custom settings
- Keep notes on which nodes work in which environment

### 4. Performance Optimization
- Use `--highvram` flag if you have sufficient GPU memory
- Monitor GPU temperature during long sessions
- Close other GPU-intensive applications when training

### 5. Organization Tips
```
C:\AI_Projects\
├── 📁 comfyui_main\          # Daily driver
├── 📁 comfyui_testing\       # Node testing
├── 📁 comfyui_training\      # Model training
├── 📁 comfyui_audio\         # Audio-specific
├── 📁 comfyui_video\         # Video-specific
└── 📁 project_archives\      # Old project backups
```

## 🎯 Workflow Examples

### Daily Content Creation
```cmd
# Use main stable environment
start_comfyui_main.bat
# Port 8188, stable nodes only
```

### Testing New Nodes
```cmd
# Use experimental environment  
start_comfyui_experimental.bat
# Port 8189, test new nodes here first
```

### Model Training
```cmd
# Use training environment
start_comfyui_training.bat
# Port 8190, all training dependencies available
```

### Multiple Projects Simultaneously
```cmd
# Run multiple instances for different clients/projects
start_comfyui_main.bat       # Client A - Port 8188
start_comfyui_experimental.bat # Client B - Port 8189
```

## 📞 Support

### Getting Help
1. **Check logs**: `ComfyUI\user\comfyui.log`
2. **Run diagnostics**: `check_installations.bat`
3. **Verify installation**: Use management menu in launcher

### Common Recovery Steps
1. If an environment gets corrupted, delete it and recreate
2. Models are safe in shared directory
3. Custom nodes can be reinstalled quickly

### Performance Monitoring
```cmd
# Monitor GPU usage
nvidia-smi -l 1

# Check system resources
tasklist | findstr python
```

This approach gives you maximum flexibility while maintaining stability. Start with one main environment and expand as needed!
