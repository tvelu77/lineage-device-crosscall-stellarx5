# LineageOS port — Crosscall Stellar X5 (`stellarx5`)

## Statut des prérequis (vérifiés sur l'appareil)

| Check | Résultat |
|---|---|
| `fastboot flashing get_unlock_ability` | `1` (bootloader déverrouillable) |
| `ro.treble.enabled` | `true` (GSI possibles) |
| `ro.build.ab_update` | `true` (A/B, slot actif : b) |
| `ro.product.cpu.abi` | `arm64-v8a` |
| Android stock | 15 → on vise **LineageOS 22.2** |
| Plateforme | `product: lahaina` (Qualcomm SM8350), bootloader UEFI, noyau 5.4.226 |
| Sources kernel | `CrosscallEngineering/StellarX5_kernel_msm-5.4` (branche `release`) |

## Arborescence du repo

- `device/crosscall/stellarx5/` — device tree (à symlinker dans l'arbre LineageOS)
- `vendor/crosscall/stellarx5/` — extraction des blobs propriétaires (à symlinker)
- `scripts/` — scripts côté téléphone/PC
- `local_manifests/crosscall.xml` — déclaration du kernel Crosscall

## Point dur connu : le drop kernel public est incomplet

`StellarX5_kernel_msm-5.4` ne contient **ni** les DTS `sm8350*`/`lahaina*` (ni `vendor/lahaina_defconfig`, seulement des fragments GKI). Plan : décompiler le DTB du boot stock + la partition `dtbo` avec `dtc`, restaurer les dtsi SoC depuis un arbre lahaina msm-5.4 public (ex. `LineageOS/android_kernel_oneplus_sm8350`), et écrire le board dts spécifique.

## Build (machine Linux, ~300 Go libres, 16–32 Go RAM)

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-22.2
mkdir -p .repo/local_manifests
cp /path/to/this-repo/local_manifests/crosscall.xml .repo/local_manifests/
repo sync -j"$(nproc)"

mkdir -p device/crosscall vendor/crosscall
ln -s /path/to/this-repo/device/crosscall/stellarx5 device/crosscall/stellarx5
ln -s /path/to/this-repo/vendor/crosscall/stellarx5 vendor/crosscall/stellarx5

# après le dump des partitions :
cd vendor/crosscall/stellarx5
./extract-files.py -d /path/to/dump
./setup-makefiles.py
cd -

source build/envsetup.sh
breakfast stellarx5
brunch stellarx5
```

## Phases côté appareil

1. `scripts/00-unlock-and-backup.sh dump/` — unlock + **dump complet** (à conserver précieusement : aucun firmware officiel Crosscall n'existe)
2. `scripts/10-flash-gsi.sh <gsi.img> dump/` — quick win : GSI TrebleDroid `arm64-ab` vanilla
3. build LineageOS puis `scripts/20-flash-lineage.sh out/target/product/stellarx5`

## Boucle d'itération

flash → boot (ou pas) → coller ici `adb logcat`, `dmesg`, `last_kmsg` → correction du device tree → rebuild → reflash.
