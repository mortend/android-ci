#!/bin/bash

# This script will download the Android SDK and NDK, and tell uno where they are.

SELF=`echo $0 | sed 's/\\\\/\\//g'`
cd "`dirname "$SELF"`" || exit 1
trap 'echo -e "\nERROR: Install failed, please check logs -- or try \"git clean -dxf .fuse\"."; exit 1' ERR

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
        curl -s -L $url --output $zip
    fi

    unzip -q $zip -d $dir
}

get-zip https://dl.google.com/android/repository/sdk-tools-windows-4333796.zip android-sdk

echo "Accepting licenses..."
yes | android-sdk/tools/bin/sdkmanager.bat --licenses > /dev/null

echo "Installing NDK..."
android-sdk/tools/bin/sdkmanager.bat ndk-bundle

# Emit config
echo "Android.SDK.Directory: android-sdk" >> .unoconfig
echo "Android.NDK.Directory: android-sdk/ndk-bundle" >> .unoconfig
