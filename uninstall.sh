#!/bin/bash

if [ "$EUID" -eq 0 ]; then
  echo "ERROR: Do not run this script as root or with sudo." >&2
  exit 1
fi

echo "Uninstalling AppImageLinker"

sudo rm -rf /usr/local/bin/AppImageLinker
echo "Main directory deleted."

systemctl --user disable --now appimage-linker.service
echo "Service disabled."

sudo rm -rf $HOME/.config/systemd/user/appimage-linker.service
sudo rm -rf $HOME/.config/AppImageLinker
echo "Configuration files deleted."

echo "All done!"