#!/bin/ash

# Enable debug logging
echo "[DEBUG] sonarr_sourcepath: $sonarr_sourcepath" >> /tmp/elf-import.log.log
echo "[DEBUG] sonarr_destinationpath: $sonarr_destinationpath" >> /tmp/elf-import.log.log
echo "[DEBUG] symlinked_dir: $symlinked_dir" >> /tmp/elf-import.log.log
echo "[DEBUG] parent_dir: $parent_dir" >> /tmp/elf-import.log.log

echo "[DEBUG] Checking if sonarr_sourcepath contains '/storage/symlinks'" >> /tmp/elf-import.log.log
if echo "$sonarr_sourcepath" | grep -q "/storage/symlinks"; then
    echo "[DEBUG] Moving file from $sonarr_sourcepath to $sonarr_destinationpath" >> /tmp/elf-import.log.log
    mv "$sonarr_sourcepath" "$sonarr_destinationpath"
else
    symlink_target="$symlinked_dir/$(basename "$parent_dir")/$(basename "$sonarr_sourcepath")"
    echo "[DEBUG] Creating symlink from $symlink_target to $sonarr_destinationpath" >> /tmp/elf-import.log.log
    ln -s "$symlink_target" "$sonarr_destinationpath"
fi
