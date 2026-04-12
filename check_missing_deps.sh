#!/bin/bash
PROP_DIR="../../../vendor/rainx/theloop/proprietary"
STOCK_DIR=~/stock

echo "🔍 Scanning extracted blobs for missing dependencies..."
echo "----------------------------------------------------"

# 1. Get a list of all libraries we ALREADY have extracted
# (We strip paths to just get filenames like 'libfoo.so')
find $PROP_DIR -name "*.so" -exec basename {} \; | sort -u > installed_libs.txt

# 2. Scan every extracted blob to see what it NEEDS
find $PROP_DIR -name "*.so" | while read blob; do
    # Use readelf to find dependencies (DT_NEEDED)
    deps=$(readelf -d "$blob" 2>/dev/null | grep NEEDED | sed -E 's/.*\[(.*)\]/\1/')
    
    for dep in $deps; do
        # Ignore common Android base libs (to reduce noise)
        if [[ "$dep" == "libc.so" || "$dep" == "libm.so" || "$dep" == "libdl.so" || "$dep" == "liblog.so" || "$dep" == "libutils.so" || "$dep" == "libcutils.so" || "$dep" == "libhardware.so" || "$dep" == "libhidlbase.so" ]]; then
            continue
        fi

        # Check if we already have this lib
        if ! grep -q "^$dep$" installed_libs.txt; then
            # We don't have it extracted. Does it exist in the stock dump?
            loc=$(find $STOCK_DIR -name "$dep" | head -n 1)
            
            if [[ ! -z "$loc" ]]; then
                # Clean up the path for the proprietary-files.txt format
                clean_path=$(echo "$loc" | sed 's/.*\/stock\///')
                echo "$clean_path"
            fi
        fi
    done
done | sort -u > missing_files.txt

echo "✅ Scan complete. Here are the missing files found in your dump:"
echo "----------------------------------------------------"
cat missing_files.txt
echo "----------------------------------------------------"
