#!/bin/bash

# Apply patches to tspi_repo SDK
# This script automatically applies all patches from the patchs/ directory
# to the corresponding subdirectories in tspi_repo/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TSPI_REPO="${SCRIPT_DIR}/../tspi_repo"
PATCH_DIR="${SCRIPT_DIR}/../patchs"

echo "=== Starting Patch Application ==="

# Check if tspi_repo directory exists
if [ ! -d "${TSPI_REPO}" ]; then
    echo "Error: tspi_repo directory does not exist. Please extract the SDK first."
    exit 1
fi

# Apply buildroot patches
if [ -d "${PATCH_DIR}/buildroot" ] && [ -d "${TSPI_REPO}/buildroot" ]; then
    echo ""
    echo "[1/2] Applying buildroot patches..."
    cd "${TSPI_REPO}/buildroot"

    patch_count=0
    for patch in ${PATCH_DIR}/buildroot/*.patch; do
        if [ -f "$patch" ]; then
            patch_name=$(basename "$patch")
            echo "  -> Applying: ${patch_name}"

            # Check if patch is already applied
            if git apply --check "$patch" 2>/dev/null; then
                git apply "$patch"
                echo "     Success"
                ((patch_count++))
            else
                echo "     Already applied or conflict, skipping"
            fi
        fi
    done

    if [ $patch_count -eq 0 ]; then
        echo "  (No new patches to apply)"
    else
        echo "  Applied ${patch_count} patch(es) total"
    fi
fi

# Apply kernel patches
if [ -d "${PATCH_DIR}/kernel" ] && [ -d "${TSPI_REPO}/kernel" ]; then
    echo ""
    echo "[2/2] Applying kernel patches..."
    cd "${TSPI_REPO}/kernel"

    patch_count=0
    for patch in ${PATCH_DIR}/kernel/*.patch; do
        if [ -f "$patch" ]; then
            patch_name=$(basename "$patch")
            echo "  -> Applying: ${patch_name}"

            # Check if patch is already applied
            if git apply --check "$patch" 2>/dev/null; then
                git apply "$patch"
                echo "     Success"
                ((patch_count++))
            else
                echo "     Already applied or conflict, skipping"
            fi
        fi
    done

    if [ $patch_count -eq 0 ]; then
        echo "  (No new patches to apply)"
    else
        echo "  Applied ${patch_count} patch(es) total"
    fi
fi

echo ""
echo "=== Patch Application Complete ==="
echo ""
echo "Tips:"
echo "  - If there are conflicts, please resolve them manually and rerun the script"
echo "  - See documentation: docs/patchs-usage.md"
echo "  - See modifications: docs/czzqq-changes.md"
