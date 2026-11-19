# Optional original wiringOP Android UI

The new JNI adapter and `wiringopd` root helper support the original Android 13
wiringOP UI on the CM5 tablet. The helper retains root-only /dev/mem access and
accepts only the app's defined GPIO/header-bus operations. The app keeps its
system UID and is signed with the current Android platform certificate.

The original vendor APK is not part of this source repository. Preparation
scripts accept a stock APK recovered from the board's original Android 13
installation, replace its RootCmd class with the reviewed adapter, embed the
new JNI library, and generate a platform-signed prebuilt module. The product
includes the UI/helper only when that generated prebuilt is present.

This is a userdebug helper (including the existing su SELinux context), not a
production SELinux policy. GPIO pin table and readall were tested. UART, I2C,
SPI, hardware PWM, electrical output and interrupts require enabled header
controllers and suitable test wiring; those transactions are not validated.
