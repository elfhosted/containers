#!/bin/ash

LOG_FILE="/tmp/elf-import.log"
echo "--- Script started at $(date) ---" >> "$LOG_FILE"

echo "sonarr_sourcepath: $sonarr_sourcepath" >> "$LOG_FILE"
echo "sonarr_destinationpath: $sonarr_destinationpath" >> "$LOG_FILE"

# Check if sonarr_sourcepath contains the string "/storage/symlinks"
if echo "$sonarr_sourcepath" | grep -q "/storage/symlinks"; then
    echo "Moving file as it is in /storage/symlinks" >> "$LOG_FILE"
    mv "$sonarr_sourcepath" "$sonarr_destinationpath"
    echo "Move completed successfully" >> "$LOG_FILE"
    exit 0
else
    # Get the parent directory of sonarr_sourcepath
    parent_dir=$(dirname "$sonarr_sourcepath")
    grandparent_dir=$(dirname "$parent_dir")
    greatgrandparent_dir=$(dirname "$grandparent_dir")
    greatgreatgrandparent_dir=$(dirname "$greatgrandparent_dir")

    echo "Parent directory: $parent_dir" >> "$LOG_FILE"
    echo "Grandparent directory: $grandparent_dir" >> "$LOG_FILE"
    echo "Great-grandparent directory: $greatgrandparent_dir" >> "$LOG_FILE"
    echo "Great-great-grandparent directory: $greagreatgrandparent_dir" >> "$LOG_FILE"

    if [[ "$parent_dir" == */downloads ]]; then
        downloads_dir="$parent_dir"
    elif [[ "$grandparent_dir" == */downloads ]]; then
        downloads_dir="$grandparent_dir"
    elif [[ "$greatgrandparent_dir" == */downloads ]]; then
        downloads_dir="$greatgrandparent_dir"        
    else
        downloads_dir="$greatgreatgrandparent_dir"
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
    mv "$sonarr_sourcepath" "$symlinked_dir/"
    echo "Moved $sonarr_sourcepath to $symlinked_dir/" >> "$LOG_FILE"

    # Create a symlink at sonarr_destinationpath pointing to the copied file
    ln -s "$symlinked_dir/$(basename "$sonarr_sourcepath")" "$sonarr_destinationpath"
    echo "Created symlink: $sonarr_destinationpath -> $symlinked_dir/$(basename "$sonarr_sourcepath")" >> "$LOG_FILE"
fi

echo "--- Script completed at $(date) ---" >> "$LOG_FILE"
