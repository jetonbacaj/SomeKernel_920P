#!/bin/sh

export FIT=exynos7420-zeroflte_defconfig
export DTS=arch/arm64/boot/dts
export IMG=arch/arm64/boot
export DC=arch/arm64/configs
export BK=build_kernel
export OUT=../output
export DT=G92X_universal.dtb
export CROSS_COMPILE=../toolchains/android-toolchain-eabi/bin/aarch64-linux-android-
#export CROSS_COMPILE=../aarch64-linux-android-4.8/bin/aarch64-linux-android-

cp $IMG/Image $BK/Image

rm -rf $BK/ramdisk/lib/modules/*

find -name '*.ko' -exec cp -av {} $BK/ramdisk/lib/modules/ \;

${CROSS_COMPILE}strip --strip-unneeded $BK/ramdisk/lib/modules/*

./tools/dtbtool -o $BK/dt.img -s 2048 -p ./scripts/dtc/ $DTS/

echo -n "Make Ramdisk archive..............................."
echo

cd $BK/ramdisk
find . | cpio -o -H newc | gzip > ../ramdisk.cpio.gz
cd ..


echo -n "Make boot.img......................................"
echo
./mkbootimg --base 0x10000000 --kernel Image --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --pagesize 2048 --ramdisk ramdisk.cpio.gz --dt dt.img -o boot.img
cp boot*.img ../$OUT
echo "Done"

#echo -n "Creating flashable zip............................."
#echo
#cd ../$OUT
#xterm -e zip -r TWRP_kernel.zip *
#echo "Done"
#echo