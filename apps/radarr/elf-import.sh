#!/bin/ash

LOG_FILE="/tmp/elf-import.log"
echo "--- Script started at $(date) ---" >> "$LOG_FILE"

echo "radarr_sourcepath: $radarr_sourcepath" >> "$LOG_FILE"
echo "radarr_destinationpath: $radarr_destinationpath" >> "$LOG_FILE"

# Check if radarr_sourcepath contains the string "/storage/symlinks"
if echo "$radarr_sourcepath" | grep -q "/storage/symlinks"; then
    echo "Moving file as it is in /storage/symlinks" >> "$LOG_FILE"
    mv "$radarr_sourcepath" "$radarr_destinationpath"
    echo "Move completed successfully" >> "$LOG_FILE"
    exit 0
else
    # Get the parent directory of radarr_sourcepath
    parent_dir=$(dirname "$radarr_sourcepath")
    grantparent_dir=$(dirname "$parent_dir")
    greatgrantparent_dir=$(dirname "$grantparent_dir")

    echo "Parent directory: $parent_dir" >> "$LOG_FILE"
    echo "Grandparent directory: $grantparent_dir" >> "$LOG_FILE"
    echo "Great-grandparent directory: $greatgrantparent_dir" >> "$LOG_FILE"

    if [[ "$parent_dir" == */downloads/ ]]; then
        downloads_dir="$parent_dir"
    elif [[ "$grandparent_dir" == */downloads/ ]]; then
        downloads_dir="$grantparent_dir"
    elif [[ "$greatgrandparent_dir" == */downloads/ ]]; then
        downloads_dir="$greatgrantparent_dir"        
    else
        downloads_dir="$greatgreatgrantparent_dir"
    fi

    echo "Resolved downloads directory: $downloads_dir" >> "$LOG_FILE"

    # Create the "symlinked" directory in the parent directory
    symlinked_dir="$downloads_dir/symlinked"
    if [ ! -d "$symlinked_dir" ]; then
        mkdir -p "$symlinked_dir"
        echo "Created directory: $symlinked_dir" >> "$LOG_FILE"
        sleep 30
    else
        echo "Directory already exists: $symlinked_dir" >> "$LOG_FILE"
    fi
    echo "Created directory: $symlinked_dir" >> "$LOG_FILE"

    # Move the source file to the new directory (so that the aarr can't delete it)
    mv "$radarr_sourcepath" "$symlinked_dir/"
    echo "Moved $radarr_sourcepath to $symlinked_dir/" >> "$LOG_FILE"

    # Create a symlink at radarr_destinationpath pointing to the copied file
    ln -s "$symlinked_dir/$(basename "$radarr_sourcepath")" "$radarr_destinationpath"
    echo "Created symlink: $radarr_destinationpath -> $symlinked_dir/$(basename "$radarr_sourcepath")" >> "$LOG_FILE"
fi

echo "--- Script completed at $(date) ---" >> "$LOG_FILE"
