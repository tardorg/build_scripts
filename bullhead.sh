#!/bin/bash

# ccache
export USE_CCACHE=1

# Telegram
export ROL=nexmeme.conf

# Google Drive for Linux
export GDRIVE=/usr/bin/gdrive

# Build related
export TARGET=aosip_bullhead-userdebug
export AOSIPVER=9.0
export DEVICENAME=bullhead
export MAKETARGET=kronic

# Switch to source directory
cd ~/pie-aosip

telegram-send --config $ROL --format html "Deleting old logs now"
rm -rf log*.txt

# AOSiP Build Type
export AOSIP_BUILDTYPE=Pie

# Date and time
export BUILDDATE=$(date +%Y%m%d)
export BUILDTIME=$(date +%H%M)

# Tell everyone we are going to start building
telegram-send --config $ROL --format html "Starting build (<code>AOSiP-$AOSIPVER-$AOSIP_BUILDTYPE-$DEVICENAME-$BUILDDATE</code>)"

# Log
telegram-send --config $ROL --format html "Logging to file <code>log-$BUILDDATE-$BUILDTIME.txt</code>"
export LOGFILE=log-$BUILDDATE-$BUILDTIME.txt

# Repo sync
telegram-send --config $ROL --format html "Starting repo sync. Executing command: <code>repo sync -f --force-sync --no-tags --no-clone-bundle -c</code>"
repo sync -f --force-sync --no-tags --no-clone-bundle -c
telegram-send --config $ROL --format html "repo sync finished."

# envsetup
telegram-send --config $ROL --format html "Establishing build environment..."
source build/envsetup.sh

# repopick
telegram-send --config $ROL --format html "Executing the following repopicks"
telegram-send --config $ROL --file repopick.sh
bash repopick.sh

# lunch
telegram-send --config $ROL --format html "Starting lunch... Lunching <code>$DEVICENAME</code>"
lunch $TARGET

# installclean
telegram-send --config $ROL --format html "Removing out/ directory..."
rm -rf out/

# Build
telegram-send --config $ROL --format html "Starting build... Building target <code>$MAKETARGET</code>"
time mka $MAKETARGET -j$(nproc --all) > ./$LOGFILE &
# LAUNCH PROGRESS OBSERVER
sleep 60
while test ! -z "$(pidof soong_ui)"; do
        # Go away for 10 mins
        sleep 120
        # bot: *WAkES uP, triggered*
        # Get latest percentage
        PERCENTAGE=$(cat $LOGFILE | tail -n 1 | awk '{ print $2 }')
        # REPORT PerCentage to that damn TeLeGraM
        telegram-send --config $ROL --format html "Current percentage: $PERCENTAGE";
done
EXITCODE=$?
if [ $EXITCODE -ne 0 ]; then telegram-send --config $ROL --format html "Build failed! Check log file <code>$LOGFILE</code>"; telegram-send --config $ROL --file $LOGFILE; exit 1; fi
telegram-send --config $ROL --format html "Build finished successfully! Uploading new build..."

# Move zip to ROMs Folder
mv $OUT/AOSiP*-$AOSIP_BUILDTYPE-$DEVICENAME-$BUILDDATE.zip /home/anirudhgupta109/ROMs/AOSiP-$AOSIPVER-$AOSIP_BUILDTYPE-$DEVICENAME-$BUILDDATE.zip

# Starting upload!
telegram-send --config $ROL --format html "Uploading to Google Drive..."
gdrive upload ~/ROMs/AOSiP-$AOSIPVER-$AOSIP_BUILDTYPE-$DEVICENAME-$BUILDDATE.zip | tee -a /tmp/gdrive-$BUILDDATE-$BUILDTIME
FILEID=$(cat /tmp/gdrive-$BUILDDATE-$BUILDTIME | tail -n 1 | awk '{ print $2 }')
gdrive share $FILEID
gdrive info $FILEID | tee -a /tmp/gdrive-info-$BUILDDATE-$BUILDTIME
MD5SUM=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'Md5sum' | awk '{ print $2 }')
NAME=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'Name' | awk '{ print $2 }')
SIZE=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'Size' | awk '{ print $2 }')
DLURL=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'DownloadUrl' | awk '{ print $2 }')
echo -e "「Build completed! 」\nPackage name: <code>$NAME</code>\nSize: <code>$SIZE</code>MB\nmd5sum: <code>$MD5SUM</code>\nDownload link: $DLURL" | telegram-send --config $ROL --format html --stdin
telegram-send --config $ROL --format html "Test pls @Skittles9823 @Jasonderulo007"
telegram-send --config $ROL --format html "@anirudhgupta109"
telegram-send --config $ROL --format html "Sending logfile just incase I was retarded and called a failed build a success"
telegram-send --config $ROL --file $LOGFILE --timeout 40.0
