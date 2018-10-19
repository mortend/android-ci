#!/bin/bash

# This script will download uno and fuselibs sources and perform building.
# See 'config.sh' for configuration options.

SELF=`echo $0 | sed 's/\\\\/\\//g'`
cd "`dirname "$SELF"`" || exit 1
trap 'echo -e "\nERROR: Install failed -- please check logs, or try \"git clean -dxf .fuse\"."; exit 1' ERR
source config.sh
set -u

# Get source code archives
function get-zip {
    url=$1
    dir=$2
    zip=$2.zip

    if [ -d $dir ]; then
        echo "Have '$dir' -- skipping download"
        return
    fi

    if [ -f $zip ]; then
        echo "Have '$zip' -- skipping download"
    else
        echo "Downloading '$url'..."
        curl -s -L $url -o $zip
    fi

    unzip -q $zip
}

UNO_DIR=uno-$UNO_VERSION
FUSELIBS_DIR=fuselibs-$FUSELIBS_VERSION

get-zip https://github.com/fuse-open/uno/archive/$UNO_VERSION.zip $UNO_DIR
get-zip https://github.com/fuse-open/fuselibs/archive/$FUSELIBS_VERSION.zip $FUSELIBS_DIR

# Generate config files
echo -e "require $UNO_DIR/.unoconfig" > .unoconfig
echo -e "Packages.SourcePaths += $FUSELIBS_DIR/Source" >> .unoconfig
sed -e "s/^/$UNO_DIR\/bin\//" $UNO_DIR/bin/.unopath > .unopath

# Build uno (unless already built)
function test-uno {
    ./uno --version 1> /dev/null 2> /dev/null
    echo $?
}

if [ `test-uno` = 0 ]; then
    echo "Uno works -- skipping build"
else
    bash $UNO_DIR/scripts/build.sh
    cp $UNO_DIR/bin/uno* .
fi

# Build fuselibs
./uno doctor -e
