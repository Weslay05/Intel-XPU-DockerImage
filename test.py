import torch
import ctypes

ctypes.CDLL('libze_loader.so')
print('Level Zero loaded!')

ctypes.CDLL('libigc.so')
print('IGC loaded!')

print(torch.xpu.is_available())
print(torch.xpu.device_count())

# Create and operate on XPU tensor
x = torch.randn(1000, 1000, device='xpu')
y = torch.randn(1000, 1000, device='xpu')
z = torch.mm(x, y)  # Matrix multiplication on GPU

print(f"✅ Success! Tensor device: {z.device}")
print(f"✅ GPU: {torch.xpu.get_device_name(0)}")
