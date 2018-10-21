#!/bin/bash
set -e -u

source .fuse/config.sh
.fuse/install.sh --no-build
.fuse/uno-$UNO_VERSION/scripts/pack.sh --no-packages
.fuse/uno doctor --configuration=Release
