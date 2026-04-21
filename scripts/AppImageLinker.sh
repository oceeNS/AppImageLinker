#!/bin/bash

CONFIG_FILE="$HOME/AppImageLinker/config/appimage-dirs.conf"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Errore: File di configurazione non trovato in $CONFIG_FILE"
    exit 1
fi

mkdir -p "$DIRS"

inotifywait -m -e create -e moved_to -e delete -e moved_from --format "%e %w%f" "${DIRS[@]}" | while read -r EVENTS TARGET_FILE
do

    if [[ "${TARGET_FILE,,}" == *.appimage ]]; then
        
        FILE_NAME=$(basename "$TARGET_FILE")
        APP_NAME="${FILE_NAME%.*}"
        
        DIR_DESKTOP="$HOME/.local/share/applications"
        DIR_ICONS="$HOME/.local/share/icons"
        DESKTOP_FILE="$DIR_DESKTOP/${APP_NAME}.desktop"

        if [[ "$EVENTS" == *"CREATE"* ]] || [[ "$EVENTS" == *"MOVED_TO"* ]]; then
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] Nuova AppImage rilevata: $TARGET_FILE"
            
            chmod +x "$TARGET_FILE"
            
            mkdir -p "$DIR_DESKTOP" "$DIR_ICONS"
            
            ICON_NAME="application-x-executable"
            APP_CATEGORY="Utility;"
            
            TEMP_DIR=$(mktemp -d)
            
            pushd "$TEMP_DIR" > /dev/null
            "$TARGET_FILE" --appimage-extract > /dev/null 2>&1
            
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
Exec="$TARGET_FILE"
Icon=$ICON_NAME
Type=Application
Terminal=false
Categories=$APP_CATEGORY
EOF

            echo "File .desktop creato in: $DESKTOP_FILE (Category: $APP_CATEGORY)"
            update-desktop-database "$DIR_DESKTOP" 2>/dev/null || xdg-desktop-menu forceupdate

        elif [[ "$EVENTS" == *"DELETE"* ]] || [[ "$EVENTS" == *"MOVED_FROM"* ]]; then
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] AppImage rimossa: $TARGET_FILE"
            
            # Rimuoviamo il file .desktop se esiste
            if [ -f "$DESKTOP_FILE" ]; then
                rm "$DESKTOP_FILE"
                echo "File .desktop eliminato: $DESKTOP_FILE"
            fi
            
            rm -f "$DIR_ICONS/${APP_NAME}".{png,svg,xpm} 2>/dev/null
            
            update-desktop-database "$DIR_DESKTOP" 2>/dev/null || xdg-desktop-menu forceupdate
        fi
    fi
done