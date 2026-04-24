# AppImageLinker

AppImageLinker is a lightweight background service that automatically integrates AppImage applications into your Linux desktop environment. 

By monitoring specific directories for changes, it automatically creates `.desktop` files and extracts icons whenever a new `.appimage` file is added. When an AppImage is deleted or moved out of the directory, AppImageLinker automatically cleans up the associated shortcut and icon.

## Features
* **Automatic Integration**: Seamlessly adds AppImages to your application launcher.
* **Icon & Category Support**: Extracts the native icon and application category directly from the AppImage's internal squashfs.
* **Real-time Monitoring**: Uses `inotify-tools` to instantly detect when AppImages are added, moved, or deleted.
* **User-Space Daemon**: Runs safely as a systemd user service without requiring root privileges for daily operation.

## Prerequisites

AppImageLinker requires `inotify-tools` to monitor directory changes. The installation script will automatically attempt to install this dependency using your system's package manager (`apt`, `dnf`, or `pacman`).

## Configuration

By default, the service monitors the `$HOME/AppImages` directory. You can add custom directories to be monitored by editing the configuration file located at:

`$HOME/.config/AppImageLinker/appimage-dirs.conf`

Simply add the paths to your desired directories within the `DIRS=( ... )` array. After making changes, you must restart the service for them to take effect by running:
   ```bash
   systemctl --user restart appimage-linker.service
   ```


## Installation

1. Clone or download this repository.
2. Navigate to the repository directory in your terminal.
3. Make the installer executable and run it:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## Uninstallation

1. Navigate to AppImageLinker's directory by typing:
   ```bash
   cd /usr/local/bin/AppImageLinker
   ```
2. Make the uninstal script executable and run it:
   ```bash
   chmod +x uninstall.sh
   ./uninstall.sh
   ```

Note: If you can't find the uninstall script, you can simply download it from the repository and run it manually (it doesn't matter where you run it from).