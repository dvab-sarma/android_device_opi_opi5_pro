# Boot from the medium on which U-Boot found this script (SD or eMMC).
setenv boot_device ${devtype}
setenv boot_devnum ${devnum}
setenv boot_partnum 1
setenv fdtfile rk3588s-orangepi-cm5-tablet.dtb
if load ${boot_device} ${boot_devnum}:${boot_partnum} 0x09000000 /config.txt; then
    env import -t 0x09000000 ${filesize}
fi
if load ${boot_device} ${boot_devnum}:${boot_partnum} ${kernel_addr_r} /Image; then
    if load ${boot_device} ${boot_devnum}:${boot_partnum} ${fdt_addr_r} /${fdtfile}; then
        if load ${boot_device} ${boot_devnum}:${boot_partnum} ${ramdisk_addr_r} /ramdisk.img; then
            setenv ramdisk_size ${filesize}
            if part uuid ${boot_device} ${boot_devnum}:${boot_partnum} partuuid; then
                setenv bootargs "earlycon=uart8250,mmio32,0xfeb50000 console=ttyS2,1500000n8 loglevel=7 root=/dev/ram0 rootwait androidboot.boot_part_uuid=${partuuid} androidboot.hardware=opi5 androidboot.usbcontroller=fc000000.usb androidboot.selinux=permissive"
                booti ${kernel_addr_r} ${ramdisk_addr_r}:${ramdisk_size} ${fdt_addr_r}
            fi
        fi
    fi
fi
echo "CM5 boot failed: check boot files and UART log"
