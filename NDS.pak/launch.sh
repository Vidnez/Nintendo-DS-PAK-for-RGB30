#!/bin/sh
export HOME="$(dirname "$0")"
export PATH=$PATH:$HOME
export LD_LIBRARY_PATH=$HOME/libs

BACKUP_DIR="$HOME/backup"
SAVESTATES_DIR="$HOME/savestates"
SAVES_NDS="$SAVES_PATH/NDS"
SAVESTATES_DEST="$SAVES_NDS/Savestates"
BG_NEAREST="$HOME/bg"
BG_BILINEAR="$HOME/bg2"

BG_IMAGES="bg_vertical_2ds.png bg_vertical_ext.png bg_vertical_full.png bg_vertical_gap.png bg_vertical.png"

CURRENT_BINARY=$(grep -o "\.\/drastic[0-9]*" "$HOME/launch.sh" | head -n 1)

check_and_fix_overlays() {
    local SOURCE_DIR=$1
    
    for img in $BG_IMAGES; do
        if [ -f "$SDCARD_PATH/$img" ]; then
            if [ -f "$SOURCE_DIR/$img" ]; then
                MD5_ROOT=$(md5sum "$SDCARD_PATH/$img" | cut -d' ' -f1)
                MD5_SOURCE=$(md5sum "$SOURCE_DIR/$img" | cut -d' ' -f1)
                
                if [ "$MD5_ROOT" != "$MD5_SOURCE" ]; then
                    MD5_NEAREST=$(md5sum "$BG_NEAREST/$img" 2>/dev/null | cut -d' ' -f1)
                    MD5_BILINEAR=$(md5sum "$BG_BILINEAR/$img" 2>/dev/null | cut -d' ' -f1)
                    
                    if [ "$MD5_ROOT" = "$MD5_NEAREST" ] && [ "$CURRENT_BINARY" = "./drastic2" ]; then
                        cp -f "$BG_BILINEAR/$img" "$SDCARD_PATH/$img"
                        chattr +h "$SDCARD_PATH/$img" 2>/dev/null
                    elif [ "$MD5_ROOT" = "$MD5_BILINEAR" ] && [ "$CURRENT_BINARY" = "./drastic" ]; then
                        cp -f "$BG_NEAREST/$img" "$SDCARD_PATH/$img"
                        chattr +h "$SDCARD_PATH/$img" 2>/dev/null
                    fi
                fi
            fi
        fi
    done
}

PNG_COUNT=0
for img in $BG_IMAGES; do
    if [ -f "$SDCARD_PATH/$img" ]; then
        PNG_COUNT=$((PNG_COUNT + 1))
    fi
done

if [ "$PNG_COUNT" -lt 2 ]; then
    if [ "$CURRENT_BINARY" = "./drastic2" ]; then
        SOURCE_DIR=$BG_BILINEAR
    else
        SOURCE_DIR=$BG_NEAREST
    fi
    
    if [ -f "$SOURCE_DIR/bg_vertical_ext.png" ]; then
        cp "$SOURCE_DIR/bg_vertical_ext.png" "$SDCARD_PATH/"
        chattr +h "$SDCARD_PATH/bg_vertical_ext.png" 2>/dev/null
    fi
    
    if [ -f "$SOURCE_DIR/bg_vertical.png" ]; then
        cp "$SOURCE_DIR/bg_vertical.png" "$SDCARD_PATH/"
        chattr +h "$SDCARD_PATH/bg_vertical.png" 2>/dev/null
    fi
else
    if [ "$CURRENT_BINARY" = "./drastic2" ]; then
        check_and_fix_overlays "$BG_BILINEAR"
    else
        check_and_fix_overlays "$BG_NEAREST"
    fi
fi

mkdir -p "$BACKUP_DIR"
mkdir -p "$SAVES_NDS"
mkdir -p "$SAVESTATES_DIR"
mkdir -p "$SAVESTATES_DEST"

if [ -d "$SAVES_NDS" ] && [ "$(ls -A "$SAVES_NDS" 2>/dev/null)" ]; then
    for file in "$SAVES_NDS"/*; do
        if [ -f "$file" ]; then
            cp -f "$file" "$BACKUP_DIR/" 2>/dev/null
        fi
    done
fi

if [ -d "$SAVESTATES_DEST" ] && [ "$(ls -A "$SAVESTATES_DEST" 2>/dev/null)" ]; then
    cp -f "$SAVESTATES_DEST"/* "$SAVESTATES_DIR/" 2>/dev/null
fi

GOV_PATH=/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
GOV_USER=schedutil
CPU_PATH=/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
CPU_SPEED_PERF=2000000
echo $GOV_USER > $GOV_PATH
echo $CPU_SPEED_PERF > $CPU_PATH

while :; do
    syncsettings.elf
done &
LOOP_PID=$!

cd "$HOME"
export LD_PRELOAD=./libSDL2-2.0.so.0.3000.2
./drastic "$1" > ./nds.log 2>&1

if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    cp -f "$BACKUP_DIR"/* "$SAVES_NDS/" 2>/dev/null
fi

if [ -d "$SAVESTATES_DIR" ] && [ "$(ls -A "$SAVESTATES_DIR" 2>/dev/null)" ]; then
    cp -f "$SAVESTATES_DIR"/* "$SAVESTATES_DEST/" 2>/dev/null
fi

sync
kill $LOOP_PID