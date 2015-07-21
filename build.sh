#!/bin/bash -e
KERNEL_VERSION=3.10.17-robocore-edison

TARGET_FW=build/lib/firmware
TARGET_MOD=build/lib/modules/$KERNEL_VERSION
mkdir -p $TARGET_FW $TARGET_MOD

echo 'copying firmware...'
WIFIFW=edison-broadcom-cws/wlan/firmware
cp $WIFIFW/LICENCE.broadcom_bcm43xx $TARGET_FW/
cp $WIFIFW/fw_bcmdhd.bin_4334x_b0 $TARGET_FW/fw_bcmdhd.bin
cp $WIFIFW/bcmdhd_aob.cal_4334x_b0 $TARGET_FW/bcmdhd_aob.cal
cp $WIFIFW/bcmdhd.cal_4334x_b0 $TARGET_FW/bcmdhd.cal

if [ "$NOKERNEL" = "" ]; then
    echo 'building kernel...'
    ln -fs arch/x86/configs/i386_robocore_edison_defconfig ./edison-kernel/.config
    make CC=/usr/bin/gcc-4.8 -C edison-kernel
    cp edison-kernel/arch/x86/boot/bzImage build/vmlinuz
    make CC=/usr/bin/gcc-4.8 INSTALL_MOD_PATH=../build/ -C edison-kernel modules_install
fi

echo 'building wifi module...'
make CC=/usr/bin/gcc-4.8 INSTALL_MOD_PATH=../build/ M=$PWD/edison-broadcom-cws/wlan/driver_bcm43x -C edison-kernel
make CC=/usr/bin/gcc-4.8 INSTALL_MOD_PATH=../build/ M=$PWD/edison-broadcom-cws/wlan/driver_bcm43x -C edison-kernel modules_install
