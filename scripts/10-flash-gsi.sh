#!/usr/bin/env bash
set -euo pipefail

GSI=${1:?usage: $0 <gsi.img> [dump_dir]}
DUMP_DIR=${2:-dump}

echo "Flashing GSI: $GSI"
fastboot flash vbmeta_a "$DUMP_DIR/vbmeta_a.img" --disable-verity --disable-verification
fastboot flash vbmeta_b "$DUMP_DIR/vbmeta_b.img" --disable-verity --disable-verification
fastboot reboot fastboot
fastboot flash system "$GSI"
fastboot flash vbmeta_system_a "$DUMP_DIR/vbmeta_system_a.img" --disable-verity --disable-verification || true
fastboot flash vbmeta_system_b "$DUMP_DIR/vbmeta_system_b.img" --disable-verity --disable-verification || true
fastboot -w
fastboot set_active b 2>/dev/null || fastboot set_active a 2>/dev/null || true
fastboot reboot
echo "Done. If it does not boot, paste: adb logcat, dmesg, and last_kmsg."
