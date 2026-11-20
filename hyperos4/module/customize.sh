#!/system/bin/sh
# FontMM HyperOS4 overlay updater - existing FontMM v26.8.0-beta.10 required.
# Does not alter live /system or /product partitions.

msg() { if command -v ui_print >/dev/null 2>&1; then ui_print "$*"; else echo "$*"; fi; }
fail() { msg "[FontMM-HOS4] ERROR: $*"; if command -v abort >/dev/null 2>&1; then abort "$*"; else exit 1; fi; }

[ -n "${MODPATH:-}" ] || fail 'MODPATH unavailable; install through KernelSU/Magisk.'
OLD='/data/adb/modules/FontMM'
[ -d "$OLD" ] || fail 'Original FontMM is not installed. Install FontMM v26.8.0-beta.10 first.'
[ -d "$OLD/webroot" ] || fail 'Original FontMM WebUI is missing.'
[ -d "$OLD/FONTS" ] || fail 'Original FontMM FONTS directory missing.'
[ -f "$OLD/apply.sh" ] || fail 'Original FontMM apply.sh missing.'
[ -d "$OLD/system" ] || fail 'Original FontMM system directory missing.'

SDK="$(getprop ro.build.version.sdk 2>/dev/null)"
OS="$(getprop ro.mi.os.version.name 2>/dev/null)"
INC="$(getprop ro.build.version.incremental 2>/dev/null)"
MIUI="$(getprop ro.miui.ui.version.name 2>/dev/null)"
case "$OS $INC" in
  *OS4*|*os4*|*'4.0.'*) : ;;
  *) [ "$SDK" = '37' ] && [ -n "$MIUI$OS" ] || fail "HyperOS 4 / Android 17 not detected (sdk=$SDK, os=$OS, build=$INC)." ;;
esac
[ "$SDK" = '37' ] || fail "Android 17 (API 37) required; detected SDK $SDK."

msg '[FontMM-HOS4] Preserving installed FontMM WebUI, fonts and binary tools...'
# Copy installed module files into a staged new module (modules_update/FontMM).
# Never overwrite upgrade scripts while they are being executed.
for item in "$OLD"/* "$OLD"/.[!.]*; do
  [ -e "$item" ] || [ -L "$item" ] || continue
  base="${item##*/}"
  case "$base" in
    customize.sh|apply.sh|module.prop|disable|remove|update|skip_mount|hyperos-package|META-INF) continue ;;
  esac
  cp -pR "$item" "$MODPATH/" || fail "Could not preserve $base; check free storage."
done

mkdir -p "$MODPATH/hyperos" || fail 'Unable to create hyperos directory.'
# Retain the pre-existing ColorOS-side apply logic for English subsetting and
# management of original FontMM slots, but don't mount its ColorOS XML.
if [ -f "$OLD/hyperos/original_apply.sh" ]; then
  cp -f "$OLD/hyperos/original_apply.sh" "$MODPATH/hyperos/original_apply.sh" || fail 'Cannot restore base apply script.'
else
  cp -f "$OLD/apply.sh" "$MODPATH/hyperos/original_apply.sh" || fail 'Cannot preserve original apply script.'
fi
[ -f "$MODPATH/hyperos-package/apply.sh" ] || fail 'Package payload missing.'
for filename in apply.sh module.prop action.sh; do
  cp -f "$MODPATH/hyperos-package/$filename" "$MODPATH/$filename" || fail "Cannot install $filename."
done
for filename in hyperos_apply.sh status.sh README.md; do
  cp -f "$MODPATH/hyperos-package/$filename" "$MODPATH/hyperos/$filename" || fail "Cannot install $filename."
done
chmod 0755 "$MODPATH/apply.sh" "$MODPATH/action.sh" "$MODPATH/hyperos/"*.sh 2>/dev/null

# Remove *only* the XML overlays from the ColorOS package.
# HyperOS original XML remains untouched (never generate or replace OEM XML).
for rel in \
  system/etc/fonts.xml \
  system/etc/fonts_base.xml \
  system/etc/fonts_ule.xml \
  system/etc/font_fallback.xml \
  system/system_ext/etc/fonts_base.xml \
  system/system_ext/etc/fonts_ule.xml; do
  rm -f "$MODPATH/$rel" || fail "Could not disable ColorOS XML overlay: $rel"
done
# Update: never inherit a disabled status from old module.
rm -f "$MODPATH/disable" "$MODPATH/remove" "$MODPATH/skip_mount"

msg "[FontMM-HOS4] Detected $OS $INC, Android SDK $SDK"
msg '[FontMM-HOS4] Preparing existing font choices for Xiaomi/HyperOS font paths...'
sh "$MODPATH/apply.sh" "$MODPATH" || fail 'Font installation failed; original module remains intact until reboot.'
msg '[FontMM-HOS4] Upgrade staged successfully. Reboot to apply.'
msg '[FontMM-HOS4] FontMM WebUI and font choices were preserved.'
