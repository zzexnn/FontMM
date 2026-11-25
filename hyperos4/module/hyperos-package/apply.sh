#!/system/bin/sh
# Keep latest two complete application logs for opt-in diagnostics.
MODDIR="$1"
[ -n "$MODDIR" ] || MODDIR=/data/adb/modules/FontMM
[ -d "$MODDIR" ] || { echo '[HOS4] Module missing' >&2; exit 1; }
[ -s "$MODDIR/FONTS/hans.ttf" ] || { echo '[HOS4] Missing hans.ttf' >&2; exit 1; }
[ -f "$MODDIR/hyperos/original_apply.sh" ] || { echo '[HOS4] Missing original_apply.sh' >&2; exit 1; }
mkdir -p "$MODDIR/hyperos" || exit 1
LOG="$MODDIR/hyperos/last-apply.log"
TMP="$LOG.tmp.$$"
[ -f "$LOG" ] && cp -f "$LOG" "$MODDIR/hyperos/previous-apply.log" 2>/dev/null || true
apply_all() {
  echo "[HOS4] Applying at $(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null)"
  sh "$MODDIR/hyperos/original_apply.sh" "$MODDIR" || return 1
  for rel in system/etc/fonts.xml system/etc/fonts_base.xml system/etc/fonts_ule.xml system/etc/font_fallback.xml system/system_ext/etc/fonts_base.xml system/system_ext/etc/fonts_ule.xml; do
    rm -f "$MODDIR/$rel" || return 1
  done
  sh "$MODDIR/hyperos/hyperos_apply.sh" "$MODDIR" || return 1
}
( apply_all ) > "$TMP" 2>&1
RESULT=$?
printf '[HOS4] apply_exit=%s\n' "$RESULT" >> "$TMP"
if mv -f "$TMP" "$LOG"; then cat "$LOG"; else cat "$TMP"; fi
exit "$RESULT"
