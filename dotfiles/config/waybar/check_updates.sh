#!/bin/bash

CACHE="/tmp/waybar_pacman_updates"
LOCK="/tmp/waybar_pacman.lock"

# Open the lock file
exec 9> "$LOCK"

# Try to grab the lock. If successful, check updates.
if flock -n 9; then
    # Write to a temporary file first
    checkupdates | wc -l > "${CACHE}.tmp"
    # Move it to the real cache file (this is an instant, atomic action)
    mv "${CACHE}.tmp" "$CACHE"
fi

# Read the cache ONLY if it exists and has content (-s checks if size > 0)
if [ -s "$CACHE" ]; then
    cat "$CACHE"
else
    echo "0"
fi
