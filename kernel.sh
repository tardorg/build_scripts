#!/bin/bash

# Telegram
export ROL=~/build_scripts/onememe.conf

# Build related
export DEVICENAME=enchilada
export DEFCONFG=kronic_defconfig

# Path defines
export SAUCE=/home/anirudhgupta109/sdm845
export COMPRESS=/home/anirudhgupta109/kernels/compress
export OUTPUT=/home/anirudhgupta109/kernels

# Date and time
export BUILDDATE=$(date +%d%m)
export BUILDTIME=$(date +%H%M)

# Name of zip
export ZIP=IllusionKernel-$BUILDDATE-$BUILDTIME

# Tell everyone we are going to start building
#telegram-send --config $ROL --format html "Starting Kernel build <code>$ZIP</code>"
cd $SAUCE

# Log
#telegram-send --config $ROL --format html "Logging to file <code>log-$BUILDDATE-$BUILDTIME.txt</code>"
export LOGFILE=log-$BUILDDATE-$BUILDTIME.txt

# Bring up-to-date with sauce
#telegram-send --config $ROL --format html "Starting sync"
git pull
#telegram-send --config $ROL --format html "sync finished."

# Clang and GCC
#telegram-send --config $ROL --format html "Exporting Clang and GCC paths"
#export CLANG_TCHAIN=/home/anirudhgupta109/clang/clang-r328903/bin/clang
#export KBUILD_COMPILER_STRING="$(${CLANG_TCHAIN} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export CROSS_COMPILE=/home/anirudhgupta109/gcc/bin/aarch64-linux-android-
export ARCH=arm64
export SUBARCH=arm64

# installclean
#telegram-send --config $ROL --format html "Building Clean af"
rm -rf out/

# Activate venv
source ~/tmp/venv/bin/activate

# Build
telegram-send --config $ROL --format html "Starting build..."
make O=out clean && make O=out mrproper && make O=out $DEFCONFG && time make -j$(nproc --all) O=out | tee $LOGFILE
EXITCODE=$?
if [ $EXITCODE -ne 0 ]; then telegram-send --config $ROL --format html "Build failed! Check log file <code>$LOGFILE</code>"; telegram-send --config $ROL --file $LOGFILE; exit 1; fi
#telegram-send --config $ROL --format html "Build finished successfully!"

# Move Image.gz-dtb to AGKernel Folder
#telegram-send --config $ROL --format html "Removing old zImage (if any)"
rm -rf $COMPRESS/Image.gz-dtb
#telegram-send --config $ROL --format html "Copying zImage"
cp out/arch/arm64/boot/Image.gz-dtb $COMPRESS/
#telegram-send --config $ROL --format html "Switching to Archive Directory"
cd $COMPRESS
#telegram-send --config $ROL --format html "Compressing AGKernel zip"
zip $ZIP -r *
mv $ZIP $ZIP.zip


# Starting upload!
#telegram-send --config $ROL --format html "Uploading $ZIP to SourceForge..."
telegram-send --config $ROL --file $ZIP.zip
#rsync -e ssh $ZIP.zip anirudhgupta109@frs.sourceforge.net:/home/frs/project/agbuilds/AGKernel/Fabian
#telegram-send --config $ROL --format html "Upload Done!"
#export DLURL="https://sourceforge.net/projects/agbuilds/files/AGKernel/Fabian/$ZIP.zip/download"
#echo -e "AGKernel Completed! \nKernel Name: <code>$ZIP</code>\nDownload link: $DLURL \n\nSince SourceForge takes a while to process files, wait 2-3 mins for it to show" | telegram-send --config $ROL --format html --stdin
#telegram-send --config $ROL --format html "Moving Kernel zip to Archives"
mv $ZIP.zip $OUTPUT/$ZIP.zip
#telegram-send --config $ROL --format html "@anirudhgupta109 for your reference"
#cd ~/fabian
telegram-send --config $ROL --file $LOGFILE
#telegram-send --config $ROL --format html "Deleting logfile"
rm -rf $LOGFILE
cd $SAUCE
