#!/vendor/bin/sh
#
# Root-privileged helper started by init when vendor.rockchip.recovery_boot
# changes. Mirrors rebootrecovery.sh but supports both enabling and
# disabling, and is driven by the property instead of run by hand.

MOUNT_POINT=/mnt/boot_config
VALUE=$(getprop vendor.rockchip.recovery_boot)

mkdir -p $MOUNT_POINT
mount -t vfat /dev/block/by-name/boot $MOUNT_POINT

sed -i "s/recovery=.*/recovery=$VALUE/" $MOUNT_POINT/config.txt

umount $MOUNT_POINT
