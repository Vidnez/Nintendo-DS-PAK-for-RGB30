#!/bin/sh
DIR="$(dirname "$0")"
cd "$DIR"

if [ "$PLATFORM" != "rgb30" ]; then
    show.elf "$DIR/platform_error.png" 5
    exit 1
fi

NDS_PAK="$SDCARD_PATH/Emus/$PLATFORM/NDS.pak"
NDS_LAUNCH="$NDS_PAK/launch.sh"
BG_NEAREST="$NDS_PAK/bg"
BG_BILINEAR="$NDS_PAK/bg2"
IMG_DIR="$DIR/img"

OVERLAYS="bg_vertical_2ds.png bg_vertical_ext.png bg_vertical_full.png bg_vertical_gap.png bg_vertical.png"

CURRENT_BINARY=$(grep -o "\.\/drastic[0-9]*" "$NDS_LAUNCH" | head -n 1)

if [ "$CURRENT_BINARY" = "./drastic" ]; then
    show.elf "$IMG_DIR/1.png" 3
    
    sed -i 's/\.\/drastic /\.\/drastic2 /g' "$NDS_LAUNCH"
    
    FOUND_OVERLAYS=""
    for overlay in $OVERLAYS; do
        if [ -f "$SDCARD_PATH/$overlay" ]; then
            FOUND_OVERLAYS="$FOUND_OVERLAYS $overlay"
        fi
    done
    
    for overlay in $FOUND_OVERLAYS; do
        if [ -f "$BG_BILINEAR/$overlay" ]; then
            cp -f "$BG_BILINEAR/$overlay" "$SDCARD_PATH/$overlay"
            chattr +h "$SDCARD_PATH/$overlay" 2>/dev/null
        fi
    done
    
    show.elf "$IMG_DIR/bilinear_active.png" 2
    
elif [ "$CURRENT_BINARY" = "./drastic2" ]; then
    show.elf "$IMG_DIR/2.png" 3
    
    sed -i 's/\.\/drastic2 /\.\/drastic /g' "$NDS_LAUNCH"
    
    FOUND_OVERLAYS=""
    for overlay in $OVERLAYS; do
        if [ -f "$SDCARD_PATH/$overlay" ]; then
            FOUND_OVERLAYS="$FOUND_OVERLAYS $overlay"
        fi
    done
    
    for overlay in $FOUND_OVERLAYS; do
        if [ -f "$BG_NEAREST/$overlay" ]; then
            cp -f "$BG_NEAREST/$overlay" "$SDCARD_PATH/$overlay"
            chattr +h "$SDCARD_PATH/$overlay" 2>/dev/null
        fi
    done
    
    show.elf "$IMG_DIR/nearest_active.png" 2
    
else
    show.elf "$IMG_DIR/error.png" 3
fi