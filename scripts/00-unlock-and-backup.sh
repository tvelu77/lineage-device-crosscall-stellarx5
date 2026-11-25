#!/usr/bin/env bash
set -euo pipefail

DUMP_DIR=${1:-dump}
PATCHED_BOOT=${PATCHED_BOOT:-}

mkdir -p "$DUMP_DIR"

echo "[1/4] Unlocking bootloader (THIS WIPES ALL DATA ON THE PHONE)"
fastboot flashing unlock
fastboot getvar unlocked

echo "[2/4] Booting stock system to collect device info"
fastboot reboot
until adb wait-for-device shell true 2>/dev/null; do sleep 2; done
adb shell getprop > "$DUMP_DIR/prop.txt"
adb shell cat /proc/partitions > "$DUMP_DIR/partitions.txt"
adb shell "ls -l /dev/block/by-name" > "$DUMP_DIR/by-name.txt" || true
adb shell "ls -l /dev/block/mapper" > "$DUMP_DIR/mapper.txt" || true

fastboot reboot bootloader
fastboot getvar all > "$DUMP_DIR/getvar-all.txt"
fastboot getvar current-slot >> "$DUMP_DIR/getvar-all.txt"

if [ -z "$PATCHED_BOOT" ]; then
  echo "PATCHED_BOOT not set: skipping partition dump."
  echo "Patch stock boot_b (pulled in step 4) with Magisk, then re-run with:"
  echo "  PATCHED_BOOT=/path/to/magisk_patched.img $0 $DUMP_DIR"
  exit 0
fi

echo "[3/4] Temporary root: booting $PATCHED_BOOT"
fastboot boot "$PATCHED_BOOT"
until adb wait-for-device shell true 2>/dev/null; do sleep 2; done

echo "[4/4] Dumping partitions into $DUMP_DIR"
for p in boot_a boot_b vendor_boot_a vendor_boot_b dtbo_a dtbo_b vbmeta_a vbmeta_b vbmeta_system_a vbmeta_system_b modem bluetooth dsp hyp tz xbl_a xbl_b abl_a abl_b; do
  adb shell "dd if=/dev/block/by-name/$p of=/sdcard/$p.img bs=4M status=none"
  adb pull "/sdcard/$p.img" "$DUMP_DIR/$p.img"
  adb shell "rm -f /sdcard/$p.img"
done
for p in system vendor product system_ext odm vendor_dlkm; do
  adb shell "if [ -e /dev/block/mapper/$p ]; then dd if=/dev/block/mapper/$p of=/sdcard/$p.img bs=4M status=none; fi"
  adb pull "/sdcard/$p.img" "$DUMP_DIR/$p.img" 2>/dev/null || true
  adb shell "rm -f /sdcard/$p.img"
done

echo "Dump complete in $DUMP_DIR -- keep it safe, it is the only way back to stock."
