# Orange Pi CM5 Tablet — Android 17

Base: dvab-sarma's Android 17 platform and device work, with a standalone CM5
product. Build target: `aosp_opi_cm5-cp2a-userdebug`.

Repositories:
- https://github.com/G-Pereira/android_manifest_orangepi_cm5_tablet
- https://github.com/G-Pereira/android_device_orangepi_cm5_tablet
- https://github.com/G-Pereira/android_kernel_orangepi_cm5_tablet

Tested: SD boot, Android startup, HDMI 1080p60, USB-C ADB, AP6256 Wi-Fi scanning,
Bluetooth controller initialization, and wiringOP GPIO input/table reads.
LCD/touch, onboard audio, cameras, charging/battery management, wired bus loopback,
and electrical GPIO output/interrupt tests are not validated.

The image uses the CM5 tablet carrier pinout. It is a userdebug development
configuration with SELinux permissive and root-only wiringOP MMIO access.

Build instructions and source provenance are completed alongside the manifest
and kernel repositories in this feature series.
