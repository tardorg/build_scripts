sudo apt update
cd ~/
wget https://docs.google.com/uc?id=0B3X9GlR6EmbnWksyTEtCM0VfaFE&export=download
mv uc\?id\=0B3X9GlR6EmbnWksyTEtCM0VfaFE gdrive
chmod +x gdrive
sudo install gdrive /usr/local/bin/gdrive
cd ~/
git clone https://github.com/akhilnarang/scripts
cd ~/scripts
bash setup/android_build_env.sh
mkdir ~/pe
cd ~/pe
repo init -u https://github.com/PixelExperience/manifest -b pie
ccache -M 100G
mkdir -p .repo/local_manifests
wget https://raw.githubusercontent.com/tardorg/local_manifests/master/tard.xml -O .repo/local_manifests/tard.xml
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
mkdir ~/ROMs
