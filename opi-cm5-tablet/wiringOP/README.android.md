# wiringOP for Android 17 / Orange Pi CM5 Tablet

Based on official wiringOP `next`, commit
`0bb861127a77864775a306bd7cfc2e36836a66d1` (2026-11-12).
Upstream: https://github.com/orangepi-xunlong/wiringOP

## Build integration

Place this directory at `external/wiringOP` in the Android source tree.
The supplied `Android.bp` builds the 64-bit vendor modules `gpio`,
`libwiringPi`, and `libwiringPiDev`, and exports their native headers.
Add all three to the CM5 product's `PRODUCT_PACKAGES`.

```
source build/envsetup.sh
lunch aosp_opi_cm5-cp2a-userdebug
m -j$(nproc) gpio libwiringPi libwiringPiDev
```

Board detection reads the exact CM5/CM5 tablet device-tree compatible string.
The tablet uses upstream's 26-pin tablet map; `gpio` defaults to wiringPi
numbering, `-1` selects physical header numbering and `-g` selects native
Rockchip bank*32+offset numbering. Do not use the Orange Pi 5 Pro header map.

## Kernel and runtime

Register access requires `CONFIG_DEVMEM=y` and `CONFIG_STRICT_DEVMEM=y`.
Leave `CONFIG_IO_STRICT_DEVMEM` disabled for access to the GPIO/IOC/clock
register ranges. Keep `/dev/mem` root-only (0600), and use `su 0`.
The Android port does not install a setuid gpio executable or grant apps
physical-memory access. Existing SELinux policy still applies.

```
adb shell su 0 /vendor/bin/gpio -v
adb shell su 0 /vendor/bin/gpio readall
adb shell su 0 /vendor/bin/gpio -1 read 7
```

`mode`, `write`, pull controls, PWM and interrupts retain upstream behavior;
use them only with the intended header wiring. I2C/SPI/UART helpers also
require their device-tree controllers and `/dev` nodes to be enabled.
No timing, electrical or loopback claims follow from a successful readall.

The ISR child helper uses `/vendor/bin/gpio` on Android. The legacy
DRC network extension's crypt(3) authentication is unsupported on Bionic
and returns ENOTSUP; authentication is never bypassed. Local GPIO, serial,
I2C/SPI, software PWM/tone and expansion-device APIs remain in the library.

The upstream LGPL license and source headers are retained. Linux board
identification and helper paths retain their original behavior.

Android compatibility also replaces glibc byte-swap internals with compiler
built-ins. Software PWM/tone use atomic stop flags and join their threads;
creation failures return instead of waiting forever. Pseudo-pins use a
root-owned file under `/dev/wiringop` so sharing survives process exits but
is cleared by reboot, as with POSIX shared memory.

An optional `wiringop-selftest` module compiles the PWM/tone sources with mock
GPIO functions. It tests create/update/stop/recreate without touching pins:

```
m wiringop-selftest
adb push out/target/product/opi-cm5-tablet/vendor/bin/wiringop-selftest /data/local/tmp/
adb shell /data/local/tmp/wiringop-selftest
```
