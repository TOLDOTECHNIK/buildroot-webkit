#!/bin/bash

set -u
set -e

echo "Post-build: processing $@"
env

BOARD_DIR="$(dirname $0)"
