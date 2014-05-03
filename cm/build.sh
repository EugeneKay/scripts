apt-get update
apt-get upgrade -y
apt-get install -y bison build-essential curl flex git-core gnupg gperf libesd0-dev libncurses5-dev libsdl1.2-dev libwxgtk2.8-dev libxml2 libxml2-utils lzop openjdk-6-jdk openjdk-6-jre pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev g++-multilib gcc-multilib lib32ncurses5-dev lib32readline-gplv2-dev lib32z1-dev phablet-tools htop
git config --global user.name "CM Buildbot"
git config --global user.email "in@val.id"
git config --global color.ui false
mkdir /android
mkfs.ext4 /dev/xvdc
cd /android
repo init -u git://github.com/CyanogenMod/android.git -b cm-11.0
mkdir .repo/local_manifests/
curl https://raw.githubusercontent.com/EugeneKay/scripts/master/cm/muppets.xml > .repo/local_manifests/muppets.xml
repo sync -j16 -c
cd vendor/cm
./get-prebuilts
cd ../../
source build/envsetup.sh
brunch ${DEVICE}
