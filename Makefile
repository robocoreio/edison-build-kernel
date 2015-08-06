KERNEL_VERSION=3.10.17-robocore-edison

TARGET_FW=build/lib/firmware
TARGET_MOD=build/lib/modules/$(KERNEL_VERSION)

WIFIFW=edison-broadcom-cws/wlan/firmware

all: build/vmlinuz firmware wifi

firmware: $(TARGET_FW)/fw_bcmdhd.bin
wifi: build/lib/modules/3.10.17-robocore-edison/extra/bcm4334x.ko

$(TARGET_FW)/fw_bcmdhd.bin:
	echo 'copying firmware...'
	cp $(WIFIFW)/LICENCE.broadcom_bcm43xx $(TARGET_FW)/
	cp $(WIFIFW)/fw_bcmdhd.bin_4334x_b0 $(TARGET_FW)/fw_bcmdhd.bin
	cp $(WIFIFW)/bcmdhd_aob.cal_4334x_b0 $(TARGET_FW)/bcmdhd_aob.cal
	cp $(WIFIFW)/bcmdhd.cal_4334x_b0 $(TARGET_FW)/bcmdhd.cal

build/lib/modules/3.10.17-robocore-edison/extra/bcm4334x.ko: build/vmlinuz
	echo 'building wifi module...'
	+make CC=/usr/bin/gcc-4.8 INSTALL_MOD_PATH=../build/ M=../edison-broadcom-cws/wlan/driver_bcm43x -C edison-kernel
	+make CC=/usr/bin/gcc-4.8 INSTALL_MOD_PATH=../build/ M=../edison-broadcom-cws/wlan/driver_bcm43x -C edison-kernel modules_install

build/vmlinuz: i386_robocore_edison_defconfig
	mkdir -p $(TARGET_FW) $(TARGET_MOD)

	echo 'building kernel...'
	cp i386_robocore_edison_defconfig edison-kernel/.config
	+make CC=/usr/bin/gcc-4.8 -C edison-kernel
	cp edison-kernel/arch/x86/boot/bzImage build/vmlinuz
	+make CC=/usr/bin/gcc-4.8 INSTALL_MOD_PATH=../build/ -C edison-kernel modules_install

.PHONY: firmware wifi
