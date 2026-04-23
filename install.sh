#!/bin/bash

# This script is used to install the AppImageLinker

#if [ "$EUID" -ne 0 ]
#  then echo "Please run as root"
#  exit
#fi

echo "Installing AppImageLinker"

PACKAGE_NAME="inotify-tools"

echo "Verifying dependencies..."

# 1. DEBIAN / UBUNTU
if command -v apt-get &> /dev/null; then

    if dpkg -s "$PACKAGE_NAME" &> /dev/null; then
        echo "[OK] $PACKAGE_NAME already installed."
    else
        echo "[INFO] $PACKAGE_NAME not found. Attempting to install using apt..."
        sudo apt update
        sudo apt install -y "$PACKAGE_NAME"
    fi

# 2. FEDORA / RHEL
elif command -v dnf &> /dev/null; then

    if rpm -q "$PACKAGE_NAME" &> /dev/null; then
        echo "[OK] $PACKAGE_NAME Already installed."
    else
        echo "[INFO] $PACKAGE_NAME not found. Attempting to install using dnf..."
        sudo dnf install -y "$PACKAGE_NAME"
    fi

# 3. ARCH LINUX
elif command -v pacman &> /dev/null; then

    if pacman -Q "$PACKAGE_NAME" &> /dev/null; then
        echo "[OK] $PACKAGE_NAME already installed."
    else
        echo "[INFO] $PACKAGE_NAME not found. Attempting to install using pacman..."
        sudo pacman -Sy --noconfirm "$PACKAGE_NAME"
    fi

# 4. FALLBACK (OS NON SUPPORTATO)
else
    echo "[ERRORE] Unknown package manager found."
    echo "Please, install '$PACKAGE_NAME' manually using your package manager before running this script."
    exit 1
fi

echo "Dependecies met. Installing..."
sudo cp -r $PWD /usr/local/bin/ && sudo chown $USER:$USER /usr/local/bin/AppImageLinker
cp config/appimage-linker.service $HOME/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now appimage-linker.service

echo "All done!"
echo "You can now delete this directory."
