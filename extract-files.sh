#!/bin/bash

# 1. Define where the files are coming from
SRC=$1
if [ -z "$SRC" ]; then
    echo "Usage: $0 <path-to-workspace>"
    exit 1
fi

# 2. Define where they are going
VENDOR_DIR=../../../vendor/rainx/theloop/proprietary
mkdir -p $VENDOR_DIR

# 3. Read the list and copy
echo "Pulling files from $SRC..."
while read -r line; do
    # Skip comments (#) and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue

    # Clean the line (remove '- ' prefix if present and split options)
    FILE_PATH=$(echo "$line" | sed 's/^-//g' | cut -d':' -f1 | tr -d '[:space:]')

    # Calculate destination
    DEST="$VENDOR_DIR/$FILE_PATH"
    DEST_DIR=$(dirname "$DEST")
    mkdir -p "$DEST_DIR"

    # Try to find the file in the workspace (checking common subfolders)
    if [ -f "$SRC/$FILE_PATH" ]; then
        cp "$SRC/$FILE_PATH" "$DEST"
    elif [ -f "$SRC/system/$FILE_PATH" ]; then
        cp "$SRC/system/$FILE_PATH" "$DEST"
    elif [ -f "$SRC/vendor/$FILE_PATH" ]; then
        cp "$SRC/vendor/$FILE_PATH" "$DEST"
    elif [ -f "$SRC/product/$FILE_PATH" ]; then
        cp "$SRC/product/$FILE_PATH" "$DEST"
    elif [ -f "$SRC/system_ext/$FILE_PATH" ]; then
        cp "$SRC/system_ext/$FILE_PATH" "$DEST"
    else
        # Optional: Print missing files (lots will be missing, that's normal for a generic tree)
        # echo "Missing: $FILE_PATH"
        true
    fi
done < proprietary-files.txt

echo "Done! Blobs are in vendor/rainx/theloop/proprietary"
