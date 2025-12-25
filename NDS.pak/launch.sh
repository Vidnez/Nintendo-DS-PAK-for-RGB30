#!/bin/sh
export HOME="$(dirname "$0")"
export PATH=$PATH:$HOME
export LD_LIBRARY_PATH=$HOME/libs


ROMS_ROOT="/storage/roms"
BG_SOURCE="$HOME/bg"
SAVES_DIR="/storage/roms/Saves/NDS"
BACKUP_DIR="$HOME/backup"
SAVESTATES_DIR="$HOME/savestates"
SAVESTATES_DEST="$SAVES_DIR/Savestates"


BG_IMAGES="bg_vertical_2ds.png bg_vertical_ext.png bg_vertical_full.png bg_vertical_gap.png bg_vertical.png"
PNG_COUNT=0

for img in $BG_IMAGES; do
    if [ -f "$ROMS_ROOT/$img" ]; then
        PNG_COUNT=$((PNG_COUNT + 1))
    fi
done

if [ "$PNG_COUNT" -lt 2 ]; then

    if [ -f "$BG_SOURCE/bg_vertical_ext.png" ]; then
        cp "$BG_SOURCE/bg_vertical_ext.png" "$ROMS_ROOT/"
        chattr +h "$ROMS_ROOT/bg_vertical_ext.png" 2>/dev/null || chmod +h "$ROMS_ROOT/bg_vertical_ext.png" 2>/dev/null
    fi
    
    if [ -f "$BG_SOURCE/bg_vertical.png" ]; then
        cp "$BG_SOURCE/bg_vertical.png" "$ROMS_ROOT/"
        chattr +h "$ROMS_ROOT/bg_vertical.png" 2>/dev/null || chmod +h "$ROMS_ROOT/bg_vertical.png" 2>/dev/null
    fi
fi


mkdir -p "$BACKUP_DIR"
mkdir -p "$SAVES_DIR"
mkdir -p "$SAVESTATES_DIR"
mkdir -p "$SAVESTATES_DEST"


if [ -d "$SAVES_DIR" ] && [ "$(ls -A "$SAVES_DIR" 2>/dev/null)" ]; then

    for file in "$SAVES_DIR"/*; do
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
    cp -f "$BACKUP_DIR"/* "$SAVES_DIR/" 2>/dev/null
fi


if [ -d "$SAVESTATES_DIR" ] && [ "$(ls -A "$SAVESTATES_DIR" 2>/dev/null)" ]; then
    cp -f "$SAVESTATES_DIR"/* "$SAVESTATES_DEST/" 2>/dev/null
fi

sync
kill $LOOP_PID