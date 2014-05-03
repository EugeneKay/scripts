apt-get update
apt-get upgrade -y
apt-get install bison build-essential curl flex git-core gnupg gperf libesd0-dev libncurses5-dev libsdl1.2-dev libwxgtk2.8-dev libxml2 libxml2-utils lzop openjdk-6-jdk openjdk-6-jre pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev g++-multilib gcc-multilib lib32ncurses5-dev lib32readline-gplv2-dev lib32z1-dev phablet-tools htop
mkdir -p /data/android
cd /data/android
repo init -u git://github.com/CyanogenMod/android.git -b cm-11.0
curl muppets.xml > .repo/local_manifests/muppets.xml
repo sync -j16 -c
cd vendor/cm
./get-prebuilts
cd ../..
source build/envsetup.sh
breakfast hammerhead
export USE_CCACHE=1
croot
brunch hammerhead
