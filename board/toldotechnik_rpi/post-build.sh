#!/bin/bash

set -u
set -e

echo "Post-build: processing $@"
env

BOARD_DIR="$(dirname $0)"

# Newer WPEWebKit requires WEBKIT_LEGACY_INSPECTOR_SERVER for the inspector to work correctly when using WPELauncher
if [ -e "${TARGET_DIR}/usr/bin/wpe" ]; then
	sed -i 's/WEBKIT_INSPECTOR_SERVER/WEBKIT_LEGACY_INSPECTOR_SERVER/' "${TARGET_DIR}/usr/bin/wpe"
fi
