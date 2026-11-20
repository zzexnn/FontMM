#!/system/bin/sh
# FontMM for HyperOS4: existing WebUI calls this script when user taps Apply.
MODDIR="${1:-/data/adb/modules/FontMM}"
[ -d "$MODDIR" ] || { echo '[FontMM-HOS4] Module directory not found'; exit 1; }
[ -s "$MODDIR/FONTS/hans.ttf" ] || { echo '[FontMM-HOS4] Select a valid Simplified Chinese font first.'; exit 1; }

# Retain original FontMM's Unicode subsetting and slot fallback behavior.
if [ -f "$MODDIR/hyperos/original_apply.sh" ]; then
  sh "$MODDIR/hyperos/original_apply.sh" "$MODDIR" || {
    echo '[FontMM-HOS4] Original font processing failed; no HyperOS overlay committed.'
    exit 1
  }
else
  echo '[FontMM-HOS4] Missing original_apply.sh; upgrade installation is incomplete.'
  exit 1
fi

# Advanced FontMM utility may recreate ColorOS XML. Do not mount those files
# on HyperOS 4; we overlay only OEM-referenced font binaries.
for rel in \
  system/etc/fonts.xml system/etc/fonts_base.xml system/etc/fonts_ule.xml \
  system/etc/font_fallback.xml system/system_ext/etc/fonts_base.xml \
  system/system_ext/etc/fonts_ule.xml; do
  rm -f "$MODDIR/$rel" || exit 1
done
sh "$MODDIR/hyperos/hyperos_apply.sh" "$MODDIR"
