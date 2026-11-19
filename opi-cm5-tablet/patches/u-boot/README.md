# U-Boot source and CM5 delta

Base: AOSP `platform/external/u-boot` at
`adffd291a17b6c017e73fc6075b91044834f4a26`, as provided by the kernel workspace
used with dvab-sarma's Android build. The manifest pins this source separately
from Linux. This patch adds the tablet defconfig/DTS, eMMC/SD aliases, and the
binman BL31/TPL handoff used by the validated SD image. The boot script selects
the actual boot medium and loads the CM5 DTB.

The original board wiring is derived from Orange Pi's Android 13 CM5 tablet
DTS; existing SPDX notices are retained. Host/source paths are configurable.
Firmware inputs used by the tested build:
- `rk3588_bl31_v1.45.elf`
- `rk3588_ddr_lp4_2112MHz_lp5_2400MHz_v1.16.bin`

Set `BL31` and `ROCKCHIP_TPL` to those stock Rockchip firmware files. They are
not copied from a user's flashed device into this source repository.
