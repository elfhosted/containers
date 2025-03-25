#!/bin/ash

# Check if radarr_sourcepath contains the string "/storage/symlinks"
if echo "$radarr_sourcepath" | grep -q "/storage/symlinks"; then
    cp "$radarr_sourcepath" "$radarr_destinationpath"
    exit 0
else
    # Get the parent directory of radarr_sourcepath
    parent_dir=$(dirname "$radarr_sourcepath")
    
    # Create the "symlinked" directory in the parent directory
    symlinked_dir="$parent_dir/symlinked"
    mkdir -p "$symlinked_dir"
    
    # Move the source file to the new directory (so that the aarr can't delete it)
    mv "$radarr_sourcepath" "$symlinked_dir/"

    # Create a symlink at radarr_destinationpath pointing to the copied file
    ln -s "$symlinked_dir/$(basename "$radarr_sourcepath")" "$radarr_destinationpath"
fi
