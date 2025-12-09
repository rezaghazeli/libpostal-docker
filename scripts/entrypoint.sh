#!/bin/sh
set -e

DATA_DIR="/data"
# Default to 'default' (OpenStreetMap) if not set
MODEL_TYPE=${MODEL:-default}
METADATA_FILE="$DATA_DIR/libpostal/.model_type"

# 1. Check if /data is actually a mount point
# We skip this check if SKIP_MOUNT_CHECK is set (useful for simple tests)
if [ -z "$SKIP_MOUNT_CHECK" ] && ! mountpoint -q "$DATA_DIR"; then
    echo "❌ ERROR: You must mount a volume to $DATA_DIR"
    echo ""
    echo "   Libpostal requires ~2GB of model data to function."
    echo "   To keep the Docker image size small, this data is NOT included in the image."
    echo "   The container will automatically download this data to $DATA_DIR on startup."
    echo ""
    echo "   ⚠️  CRITICAL: To avoid re-downloading 2GB of data every time you run this container,"
    echo "      you MUST mount a local directory to $DATA_DIR to persist the model files."
    echo ""
    echo "   Usage example:"
    echo "   docker run -p 8080:8080 -v /your/local/cache/dir:$DATA_DIR libpostal-rest"
    exit 1
fi

# 2. Check for existing data and model mismatch
if [ -f "$DATA_DIR/libpostal/address_parser/address_parser_crf.dat" ]; then
    if [ -f "$METADATA_FILE" ]; then
        EXISTING_MODEL=$(cat "$METADATA_FILE")    
        if [ "$EXISTING_MODEL" != "$MODEL_TYPE" ]; then
            echo "❌ ERROR: Model mismatch!"
            echo "   Requested model: '$MODEL_TYPE'"
            echo "   Existing data is: '$EXISTING_MODEL'"
            echo ""
            echo "   You cannot switch models on an existing data volume."
            echo "   Please mount a different volume or empty the current one."
            exit 1
        fi
        echo "✅ Found existing '$MODEL_TYPE' data. Skipping download."
    else
        # Fallback for legacy data or manual data download (assume it matches and just warn user)
        echo "⚠️  Found existing data without a metadata tag."
        echo "   Assuming it is compatible. If you experience errors, clear the volume."
    fi
else
    # 3. Download Data
    echo "⬇️  Downloading '$MODEL_TYPE' data..."

    # Ensure directory exists
    mkdir -p "$DATA_DIR/libpostal"

    if [ "$MODEL_TYPE" = "default" ]; then
        echo "   Using Default downloader..."
        libpostal_data_default download all "$DATA_DIR/libpostal"
    elif [ "$MODEL_TYPE" = "senzing" ]; then
        echo "   Using Senzing downloader..."
        libpostal_data_senzing download all "$DATA_DIR/libpostal"
    else
        echo "❌ ERROR: Unknown model type '$MODEL_TYPE'. Use 'senzing' or 'default'."
        exit 1
    fi
    
    # Write the metadata file
    echo "$MODEL_TYPE" > "$METADATA_FILE"
    echo "✅ Download complete. Tagged as '$MODEL_TYPE'."
fi

# 4. Execute the command passed to docker run
exec "$@"
