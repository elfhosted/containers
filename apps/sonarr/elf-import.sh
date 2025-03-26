#!/bin/ash

# Enable debug logging
echo "[DEBUG] sonarr_sourcepath: $sonarr_sourcepath" >> /tmp/elf-import.log
echo "[DEBUG] sonarr_destinationpath: $sonarr_destinationpath" >> /tmp/elf-import.log
echo "[DEBUG] symlinked_dir: $symlinked_dir" >> /tmp/elf-import.log
echo "[DEBUG] parent_dir: $parent_dir" >> /tmp/elf-import.log

echo "[DEBUG] Checking if sonarr_sourcepath contains '/storage/symlinks'" >> /tmp/elf-import.log
if echo "$sonarr_sourcepath" | grep -q "/storage/symlinks"; then
    echo "[DEBUG] Moving file from $sonarr_sourcepath to $sonarr_destinationpath" >> /tmp/elf-import.log
    mv "$sonarr_sourcepath" "$sonarr_destinationpath"
else

    filename=$(basename "$sonarr_sourcepath")
    containing_folder=$(dirname "$sonarr_sourcepath")
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
    mv "$sonarr_sourcepath" "$symlink_target/"

    symlink_from="$symlink_target/$(basename "$sonarr_sourcepath")"

    echo "[DEBUG] Creating symlink from $symlink_from to $sonarr_destinationpath" >> /tmp/elf-import.log
    ln -s "$symlink_from" "$sonarr_destinationpath"
fi
