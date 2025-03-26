#!/bin/ash

# Check if sonarr_sourcepath contains the string "/storage/symlinks"
if echo "$sonarr_sourcepath" | grep -q "/storage/symlinks"; then
    mv "$sonarr_sourcepath" "$sonarr_destinationpath"
    exit 0
else
    # Get the parent directory of sonarr_sourcepath
    parent_dir=$(dirname "$sonarr_sourcepath")
    grantparent_dir=$(dirname "$parent_dir")
    greatgrantparent_dir=$(dirname "$grantparent_dir")
    
    if [[ "$parent_dir" == */downloads/ ]]; then
        downloads_dir="$parent_dir"
    elif [[ "$grandparent_dir" == */downloads/ ]]; then
        downloads_dir="$grantparent_dir"
    else
        downloads_dir="$greatgrantparent_dir"
    fi

    # Create the "symlinked" directory in the parent directory
    symlinked_dir="$downloads_dir/symlinked"
    mkdir -p "$symlinked_dir"
    
    # Move the source file to the new directory (so that the aarr can't delete it)
    mv "$sonarr_sourcepath" "$symlinked_dir/"

    # Create a symlink at sonarr_destinationpath pointing to the copied file
    ln -s "$symlinked_dir/$(basename "$sonarr_sourcepath")" "$sonarr_destinationpath"
fi
