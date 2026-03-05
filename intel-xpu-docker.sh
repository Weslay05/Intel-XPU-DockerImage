docker run -it \
  --device /dev/dri \
  --group-add $(getent group render | cut -d: -f3) \
  -v $(pwd):/workspace \
  intel-xpu-env