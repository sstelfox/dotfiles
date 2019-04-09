#!/bin/bash

sudo dnf install xorg-x11-drv-nvidia akmod-nvidia xorg-x11-drv-nvidia-cuda \
  vulkan xorg-x11-drv-nvidia-cuda-libs vdpauinfo libva-vdpau-driver \
  libva-utils -y
