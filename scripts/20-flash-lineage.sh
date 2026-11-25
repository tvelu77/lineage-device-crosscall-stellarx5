#!/usr/bin/env bash
set -euo pipefail

IMGS=${1:?usage: $0 <path to out/target/product/stellarx5>}

for img in boot dtbo vendor_boot vbmeta; do
  [ -f "$IMGS/$img.img" ] || continue
  for slot in a b; do
    fastboot flash "${img}_${slot}" "$IMGS/$img.img"
  done
done
fastboot set_active a
fastboot -w
fastboot reboot
echo "Flashed LineageOS from $IMGS. If it does not boot, paste: adb logcat, dmesg, and last_kmsg."
