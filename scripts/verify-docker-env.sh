#!/bin/bash
# Docker環境の検証スクリプト

set -e

echo "==================================="
echo "SAM 3D Objects Docker Environment Verification"
echo "==================================="
echo ""

# Activate conda environment
echo "1. Activating sam3d-objects environment..."
eval "$(conda shell.bash hook)"
conda activate sam3d-objects
echo "✓ Environment activated"
echo ""

# Check Python version
echo "2. Checking Python version..."
python_version=$(python --version)
echo "   $python_version"
if [[ ! "$python_version" =~ "3.11" ]]; then
    echo "✗ Expected Python 3.11.x"
    exit 1
fi
echo "✓ Python version correct"
echo ""

# Check CUDA availability
echo "3. Checking CUDA and PyTorch..."
python -c "
import torch
import sys

print(f'   PyTorch version: {torch.__version__}')
print(f'   CUDA available: {torch.cuda.is_available()}')

if torch.cuda.is_available():
    print(f'   CUDA version: {torch.version.cuda}')
    print(f'   GPU device: {torch.cuda.get_device_name(0)}')
    print(f'   Number of GPUs: {torch.cuda.device_count()}')
    memory_gb = torch.cuda.get_device_properties(0).total_memory / 1024**3
    print(f'   GPU memory: {memory_gb:.1f} GB')
else:
    print('   WARNING: CUDA not available!')
    sys.exit(1)
"
echo "✓ CUDA configured correctly"
echo ""

# Check key packages
echo "4. Checking key packages..."
python -c "
import importlib
import sys

packages = [
    'torch',
    'torchvision', 
    'pytorch3d',
    'einops',
    'hydra',
    'numpy',
    'PIL',
    'cv2',
]

missing = []
for pkg in packages:
    try:
        mod = importlib.import_module(pkg)
        version = getattr(mod, '__version__', 'unknown')
        print(f'   ✓ {pkg}: {version}')
    except ImportError:
        print(f'   ✗ {pkg}: NOT FOUND')
        missing.append(pkg)

if missing:
    print(f'\nMissing packages: {missing}')
    sys.exit(1)
"
echo ""

# Check sam3d_objects package
echo "5. Checking sam3d_objects package..."
python -c "
import sys
sys.path.insert(0, '/workspace')
try:
    import sam3d_objects
    print('   ✓ sam3d_objects package found')
except ImportError as e:
    print(f'   ✗ sam3d_objects package not found: {e}')
    sys.exit(1)
"
echo ""

echo "==================================="
echo "✓ All checks passed!"
echo "==================================="
echo ""
echo "Environment is ready for development."
echo "You can now run: python demo.py"
