#!/bin/bash

# This script will download uno and fuselibs sources and perform building.
# See 'config.sh' for configuration options.

SELF=`echo $0 | sed 's/\\\\/\\//g'`
cd "`dirname "$SELF"`" || exit 1
trap 'echo -e "\nERROR: Install failed, please check logs -- or try \"git clean -dxff .fuse\"."; exit 1' ERR
source config.sh
set -u

# Get source code using Git
function get-git {
    url=$1
    co=$2
    dir=$3

    if [ -d $dir ]; then
        echo "Have '$dir' -- skipping download"
        return
    fi

    echo "Cloning '$dir' from $url..."
    git clone -q $url $dir
    pushd $dir > /dev/null
    git checkout -qf $co
    popd > /dev/null
}

UNO_DIR=uno-$UNO_VERSION
FUSELIBS_DIR=fuselibs-$FUSELIBS_VERSION

get-git https://github.com/fuse-open/uno.git $UNO_VERSION $UNO_DIR
get-git https://github.com/fuse-open/fuselibs.git $FUSELIBS_VERSION $FUSELIBS_DIR

# Generate config files
echo -e "require $UNO_DIR/.unoconfig" > .unoconfig
echo -e "Packages.SourcePaths += $FUSELIBS_DIR/Source" >> .unoconfig
sed -e "s/^/$UNO_DIR\/bin\//" $UNO_DIR/bin/.unopath > .unopath
cp $UNO_DIR/bin/uno* .

# Option to skip building
if [[ $# -gt 0 && "$1" == --no-build ]]; then
    exit 0
fi

# Build uno (unless already built)
function test-uno {
    ./uno --version 1> /dev/null 2> /dev/null
    echo $?
}

if [ `test-uno` = 0 ]; then
    echo "Uno works -- skipping build"
else
    bash $UNO_DIR/scripts/build.sh
fi

# Build fuselibs
./uno doctor -e
