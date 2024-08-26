#!/usr/bin/env bash
set -o pipefail -o errexit

function replace_embedded_svg_icon() {
if [ ! -f $1 ]; then echo "$1 does not exist"; exit -1; fi
if [ ! -f $2 ]; then echo "$2 does not exist"; exit -1; fi

echo "'$1' -> '$2'"

first='`$'
last='^`'
sed -i "/$first/,/$last/{ /$first/{p; r $1
}; /$last/p; d }" $2
}

# If a patch was not provided, try to choose one
if [[ -z ${PATCH_NAME} ]]; then
    # If a patch with the same name as the ref exists, use it
    if [ -f "../patches/${VAULT_VERSION}.patch" ]; then
        echo "Exact patch file found, using that"
        PATCH_NAME="${VAULT_VERSION}.patch"
    elif [ -f "../patches/legacy/${VAULT_VERSION}.patch" ]; then
        echo "Exact legacy patch file found, using that"
        echo "NOTE: This is a Legacy patch file for an older web-vault version!"
        # Sleep 10 seconds so this note might be noticed a bit better
        sleep 10
        PATCH_NAME="legacy/${VAULT_VERSION}.patch"
    else
        echo "No exact patch file not found, using latest"
        # If not, use the latest one
        PATCH_NAME="$(find ../patches/ -type f -print0 | xargs -0 basename -a | sort -V | tail -n1)"
    fi
fi

# Final check if the patch file exists, if not, exit
if [[ ! -f "../patches/${PATCH_NAME}" ]]; then
    echo "Patch file '${PATCH_NAME}' not found in the patches directory!"
    exit 1
fi

echo "Remove non-free bitwarden_license/ code"
rm -rf ./bitwarden_license/

echo "Using patch: ${PATCH_NAME}"
git apply "../patches/${PATCH_NAME}" --reject

echo "Patching successful!"
