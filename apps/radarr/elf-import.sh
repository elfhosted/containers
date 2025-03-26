#!/bin/ash

# Enable debug logging
echo "[DEBUG] radarr_sourcepath: $radarr_sourcepath" >> /tmp/elf-import.log
echo "[DEBUG] radarr_destinationpath: $radarr_destinationpath" >> /tmp/elf-import.log
echo "[DEBUG] symlinked_dir: $symlinked_dir" >> /tmp/elf-import.log
echo "[DEBUG] parent_dir: $parent_dir" >> /tmp/elf-import.log

echo "[DEBUG] Checking if radarr_sourcepath contains '/storage/symlinks'" >> /tmp/elf-import.log
if echo "$radarr_sourcepath" | grep -q "/storage/symlinks"; then
    echo "[DEBUG] Moving file from $radarr_sourcepath to $radarr_destinationpath" >> /tmp/elf-import.log
    mv "$radarr_sourcepath" "$radarr_destinationpath"
else

    filename=$(basename "$radarr_sourcepath")
    containing_folder=$(dirname "$radarr_sourcepath")
    grandparent_folder=$(dirname "$containing_folder")
    great_grandparent_folder=$(dirname "$grandparent_folder")

    echo "[DEBUG] Extracted filename: $filename" >> /tmp/elf-import.log
    echo "[DEBUG] Containing folder: $containing_folder" >> /tmp/elf-import.log
    echo "[DEBUG] Grandparent folder: $grandparent_folder" >> /tmp/elf-import.log
    echo "[DEBUG] Great-grandparent folder: $great_grandparent_folder" >> /tmp/elf-import.log

    if [ "$(basename "$containing_folder")" = "$filename" ]; then
        selected_folder="$grandparent_folder"
    elif [ "$(basename "$grandparent_folder")" = "$filename" ]; then
        selected_folder="$great_grandparent_folder"
    else
        selected_folder="$containing_folder"
    fi

    symlink_target="$selected_folder/imported-and-symlinked"
    mkdir -p "$symlink_target"

    # Move the file for safekeeping so the aars don't clean it up
    mv "$radarr_sourcepath" "$symlink_target/"

    symlink_from="$symlink_target/$(basename "$radarr_sourcepath")"

    echo "[DEBUG] Creating symlink from $symlink_from to $radarr_destinationpath" >> /tmp/elf-import.log
    ln -s "$symlink_from" "$radarr_destinationpath"
fi
