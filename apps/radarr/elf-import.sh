#!/bin/ash

# Enable debug logging
echo "[DEBUG] radarr_sourcepath: $radarr_sourcepath" >> /tmp/elf-import.log.log
echo "[DEBUG] radarr_destinationpath: $radarr_destinationpath" >> /tmp/elf-import.log.log
echo "[DEBUG] symlinked_dir: $symlinked_dir" >> /tmp/elf-import.log.log
echo "[DEBUG] parent_dir: $parent_dir" >> /tmp/elf-import.log.log

echo "[DEBUG] Checking if radarr_sourcepath contains '/storage/symlinks'" >> /tmp/elf-import.log.log
if echo "$radarr_sourcepath" | grep -q "/storage/symlinks"; then
    echo "[DEBUG] Moving file from $radarr_sourcepath to $radarr_destinationpath" >> /tmp/elf-import.log.log
    mv "$radarr_sourcepath" "$radarr_destinationpath"
else
    symlink_target="$symlinked_dir/$(basename "$parent_dir")/$(basename "$radarr_sourcepath")"
    echo "[DEBUG] Creating symlink from $symlink_target to $radarr_destinationpath" >> /tmp/elf-import.log.log
    ln -s "$symlink_target" "$radarr_destinationpath"
fi
