#!/system/bin/sh
# Standalone HyperOS 4 FontMM installer. Original FontMM by Yule (GPL-3.0).
REPLACE=""
REMOVE=""
say() { if command -v ui_print >/dev/null 2>&1; then ui_print "$*"; else echo "$*"; fi; }
die() { say "[HOS4] ERROR: $*"; if command -v abort >/dev/null 2>&1; then abort "$*"; else exit 1; fi; }
[ -n "${MODPATH:-}" ] || die "Missing MODPATH; use KernelSU/Magisk."
SDK="$(getprop ro.build.version.sdk 2>/dev/null)"
OS="$(getprop ro.mi.os.version.name 2>/dev/null)"
INC="$(getprop ro.build.version.incremental 2>/dev/null)"
MIUI="$(getprop ro.miui.ui.version.name 2>/dev/null)"
[ "$SDK" = 37 ] || die "Android 17 SDK 37 required, found $SDK."
case "$OS $INC" in
  *OS4*|*os4*|*'4.0.'*) : ;;
  *) [ -n "$MIUI$OS" ] || die "HyperOS 4 was not detected." ;;
esac
[ -s "$MODPATH/FONTS/hans.ttf" ] || die "Bundled Simplified Chinese font missing."
[ -d "$MODPATH/webroot" ] || die "Bundled FontMM WebUI missing."
[ -f "$MODPATH/hyperos/original_apply.sh" ] || die "Original font processor missing."
[ -f "$MODPATH/hyperos/hyperos_apply.sh" ] || die "HyperOS font processor missing."
[ -f "$MODPATH/zygisk/arm64-v8a.so" ] || die "Zygisk preloader missing."
[ -f "$MODPATH/tools/fontmm-wght" ] || die "Weight tool missing."
OLD="/data/adb/modules/FontMM/FONTS"
if [ -d "$OLD" ]; then
  say "[HOS4] Existing FontMM found; preserving font choices."
  for f in hans.ttf hant.ttf en.ttf mono.ttf emoji.ttf wght-mode.txt wght-map.txt; do
    [ -s "$OLD/$f" ] && cp -f "$OLD/$f" "$MODPATH/FONTS/$f" || :
  done
fi
for rel in system/etc/fonts.xml system/etc/fonts_base.xml system/etc/fonts_ule.xml system/etc/font_fallback.xml system/system_ext/etc/fonts_base.xml system/system_ext/etc/fonts_ule.xml; do
  rm -f "$MODPATH/$rel" || die "Could not remove ColorOS XML override $rel"
done
chmod 0755 "$MODPATH/apply.sh" "$MODPATH/hyperos/"*.sh 2>/dev/null
mkdir -p "$MODPATH/hyperos" || die "Cannot create diagnostic directory."
{
  echo "FontMM standalone install"
  echo "sdk=$SDK"
  echo "os=$OS"
  echo "build=$INC"
} > "$MODPATH/hyperos/install-status.txt" 2>/dev/null || true
say "[HOS4] Staging fonts for $OS $INC"
sh "$MODPATH/apply.sh" "$MODPATH" || die "Font overlay generation failed."
say "[HOS4] Standalone installation complete; reboot to apply."
