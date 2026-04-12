#!/bin/bash
DUMP_DIR=~/stock_dump
LOG_FILE=soong_errors.log

echo "Running Soong analysis (m nothing)..."
m nothing > $LOG_FILE 2>&1

# Extract missing 64-bit variants and undefined modules
MISSING_LIBS=$(grep -oP 'dependency "\K[^"]+(?=" .* missing variant:.*arm64)' $LOG_FILE)
UNDEFINED_MODS=$(grep -oP 'depends on undefined module "\K[^"]+(?=")' $LOG_FILE)

ALL_MISSING=$(echo -e "$MISSING_LIBS\n$UNDEFINED_MODS" | sort -u | grep -v '^$')

if [ -z "$ALL_MISSING" ]; then
    echo "No missing dependencies found! You are ready to build."
    exit 0
fi

echo "Found missing modules:"
echo "$ALL_MISSING"
echo "----------------------------------------"

for lib in $ALL_MISSING; do
    # Find the 64-bit .so file in the dump
    found_path=$(find $DUMP_DIR -type f -name "${lib}.so" | grep "lib64" | head -n 1)
    
    if[ -n "$found_path" ]; then
        # Convert absolute path to relative path
        rel_path=$(echo $found_path | sed "s|$DUMP_DIR/||" | sed 's|^/||')
        
        if ! grep -q "^$rel_path" proprietary-files.txt; then
            echo "Adding $rel_path to proprietary-files.txt"
            echo "$rel_path" >> proprietary-files.txt
        fi
    else
        echo "WARNING: ${lib}.so not found in $DUMP_DIR."
        echo "-> You may need to delete the module that depends on it from proprietary-files.txt"
    fi
done
