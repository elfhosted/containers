#!/bin/ash

# Check if sonarr_sourcepath contains the string "/storage/symlinks"
if echo "$sonarr_sourcepath" | grep -q "/storage/symlinks"; then
    mv "$sonarr_sourcepath" "$sonarr_destinationpath"
    exit 0
else
    # Get the parent directory of sonarr_sourcepath
    parent_dir=$(dirname "$sonarr_sourcepath")
    grandparent_dir=$(dirname "$parent_dir")
    
    # Create the "symlinked" directory in the grandparent directory
    symlinked_dir="$grandparent_dir/symlinked"
    mkdir -p "$symlinked_dir"
    
    # Move the parent dir file to the new grandparent directory (so that the aarr can't delete it)
    mv "$parent_dir" "$symlinked_dir/"

    # Create a symlink at sonarr_destinationpath pointing to the copied file
    ln -s "$symlinked_dir/$(basename "$parent_dir")/$(basename "$sonarr_sourcepath")" "$sonarr_destinationpath"
fi
