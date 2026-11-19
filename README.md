# Android 17 for the Orange Pi CM5 Tablet

This is a derivative of **dvab-sarma's Android 17 Orange Pi work**, specifically
[`android_device_opi_opi5_pro`](https://github.com/dvab-sarma/android_device_opi_opi5_pro).
Its Git history, original copyright notices, and shared HAL implementations are
retained. The CM5 work adds an independent product in `opi-cm5-tablet/`; it does
not inherit the Orange Pi 5 Pro product or BoardConfig.

The upstream product entry points are retained for mergeable development. The
CM5 manifest checks this repository out at `device/opi/cm5`. Shared HAL names
containing `opi5` remain stable Android interface identifiers; the CM5 board
configuration, boot files, pin wiring, and images live in their own directory.

See `opi-cm5-tablet/README.md` for build instructions and hardware status.
`README.upstream.md` preserves the original upstream documentation.
