# AP6256 firmware inputs

Broadcom program firmware and Bluetooth patch files are reused from
`dvab-sarma/proprietary_vendor_opi`, pinned by the CM5 manifest. They are not
duplicated here. `nvram_ap6256.txt` is the CM5 tablet's Android 13 calibration
configuration (AP6256_NVRAM_V1.3_10092019); its MAC field is the manufacturer's
placeholder, not a captured user address. The device uses its hardware address.

`regulatory.db` and its detached signature were used for the validated kernel
build. They are the upstream Linux wireless regulatory database packaged by
Ubuntu wireless-regdb. Upstream source: https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/
