#!/bin/bash

# ccache
export USE_CCACHE=1

# Build related
export TARGET=aosp_enchilada-userdebug
export DEVICENAME=enchilada
export MAKETARGET=bacon

# Go to source directory
cd ~/pe

telegram-send --config $ROL --format html "Deleting old logs now"
rm -rf log*.txt

# AOSiP Build Type
export CUSTOM_BUILD_TYPE=Tard

# Date and time
export BUILDDATE=$(date +%Y%m%d)
export BUILDTIME=$(date +%H%M)
export LOGFILE=log-$BUILDDATE-$BUILDTIME.txt

# Sync
repo sync -f --force-sync --no-tags --no-clone-bundle -c

# Setup build env
source build/envsetup.sh
lunch $TARGET

# Clear out directory but keep host stuff intact
rm -rf out/target/product

# Start build and pipe to LOGFILE
time mka $MAKETARGET -j$(nproc --all) > ./$LOGFILE
EXITCODE=$?
if [ $EXITCODE -ne 0 ]; then echo -e "Build failed! Check log file <code>$LOGFILE</code>"; exit 1; fi

# Move zip to ROMs Folder
mv $OUT/PixelExperience_$DEVICENAME-9.0-$BUILDDATE-*-$CUSTOM_BUILD_TYPE.zip ~/ROMs/PixelExperience_$DEVICENAME-9.0-$BUILDDATE-$CUSTOM_BUILD_TYPE.zip

# Starting upload!
gdrive upload ~/ROMs/PixelExperience_$DEVICENAME-9.0-$BUILDDATE-$CUSTOM_BUILD_TYPE.zip | tee -a /tmp/gdrive-$BUILDDATE-$BUILDTIME
FILEID=$(cat /tmp/gdrive-$BUILDDATE-$BUILDTIME | tail -n 1 | awk '{ print $2 }')
gdrive share $FILEID
gdrive info $FILEID | tee -a /tmp/gdrive-info-$BUILDDATE-$BUILDTIME
MD5SUM=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'Md5sum' | awk '{ print $2 }')
NAME=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'Name' | awk '{ print $2 }')
SIZE=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'Size' | awk '{ print $2 }')
DLURL=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'DownloadUrl' | awk '{ print $2 }')
echo -e "「Build completed! 」\nID: <code>$FILEID</code>\nPackage name: <code>$NAME</code>\nSize: <code>$SIZE</code>MB\nmd5sum: <code>$MD5SUM</code>\nDownload link: $DLURL"
