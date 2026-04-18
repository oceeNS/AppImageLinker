#!/bin/bash

DIRS=(
    "$HOME/AppImages"
)

inotifywait -m -e create -e moved_to --format "%w%f" "${DIRS[@]}" | while read -r NEW_FILE
do
    if [[ "${NEW_FILE,,}" == *.appimage ]]; then
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] New AppImage detected: $NEW_FILE"
            
            chmod +x "$NEW_FILE"
            
            FILE_NAME=$(basename "$NEW_FILE")
            APP_NAME="${FILE_NAME%.*}"
            
            DIR_DESKTOP="$HOME/.local/share/applications"
            DIR_ICONS="$HOME/.local/share/icons"
            DESKTOP_FILE="$DIR_DESKTOP/${APP_NAME}.desktop"
            
            mkdir -p "$DIR_DESKTOP" "$DIR_ICONS"
            
            ICON_NAME="application-x-executable"
            APP_CATEGORY="Utility;"
            
            TEMP_DIR=$(mktemp -d)
            
            pushd "$TEMP_DIR" > /dev/null
            "$NEW_FILE" --appimage-extract > /dev/null 2>&1
            
            if [ -d "squashfs-root" ]; then

                if [ -e "squashfs-root/.DirIcon" ]; then
                    ICON_SRC="squashfs-root/.DirIcon"
                else
                    ICON_SRC=$(find squashfs-root -maxdepth 1 \( -name "*.png" -o -name "*.svg" \) | head -n 1)
                fi
                
                if [ -n "$ICON_SRC" ]; then
                    REAL_FILE=$(readlink -f "$ICON_SRC")
                    EXT="${REAL_FILE##*.}"
                    cp -L "$ICON_SRC" "$DIR_ICONS/${APP_NAME}.${EXT}"
                    ICON_NAME="${APP_NAME}"
                fi

                ORIGINAL_DESKTOP=$(find squashfs-root -maxdepth 1 -name "*.desktop" | head -n 1)
                
                if [ -n "$ORIGINAL_DESKTOP" ]; then

                    EXTRACTED_CATEGORY=$(grep -m 1 "^Categories=" "$ORIGINAL_DESKTOP" | cut -d'=' -f2-)
                    
                    if [ -n "$EXTRACTED_CATEGORY" ]; then
                        APP_CATEGORY="$EXTRACTED_CATEGORY"
                    fi
                fi
            fi
            
            popd > /dev/null
            rm -rf "$TEMP_DIR"
            
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=$APP_NAME
Exec="$NEW_FILE"
Icon=$ICON_NAME
Type=Application
Terminal=false
Categories=$APP_CATEGORY
EOF

            echo "File .desktop created in: $DESKTOP_FILE (Category: $APP_CATEGORY)"
            
            update-desktop-database "$DIR_DESKTOP" 2>/dev/null || xdg-desktop-menu forceupdate
    fi
done
