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
    filename_without_ext="${filename%.*}"

    parent_folder=$(dirname "$sonarr_sourcepath")
    grandparent_folder=$(dirname "$parent_folder")
    great_grandparent_folder=$(dirname "$grandparent_folder")

    if [[ "$parent_folder" != "$filename_without_ext" ]]; then
        selected_folder="$parent_folder"
    elif [[ "$grandparent_folder" != "$filename_without_ext" ]]; then
        selected_folder="$grandparent_folder"
    else
        selected_folder="$great_grandparent_folder"
    fi

    echo "[DEBUG] Extracted filename: $filename" >> /tmp/elf-import.log
    echo "[DEBUG] Parent folder: $parent_folder" >> /tmp/elf-import.log
    echo "[DEBUG] Grandparent folder: $grandparent_folder" >> /tmp/elf-import.log
    echo "[DEBUG] Great-grandparent folder: $great_grandparent_folder" >> /tmp/elf-import.log
    echo "[DEBUG] Selected folder: $selected_folder" >> /tmp/elf-import.log

    symlink_target="$selected_folder/imported-and-symlinked"
    mkdir -p "$symlink_target"

    # Move the file for safekeeping so the aars don't clean it up
    mv "$sonarr_sourcepath" "$symlink_target/"

    symlink_from="$symlink_target/$(basename "$sonarr_sourcepath")"

    echo "[DEBUG] Creating symlink from $symlink_from to $sonarr_destinationpath" >> /tmp/elf-import.log
    ln -s "$symlink_from" "$sonarr_destinationpath"
fi