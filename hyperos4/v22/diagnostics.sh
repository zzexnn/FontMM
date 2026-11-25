#!/system/bin/sh
# FontMM HyperOS 4 diagnostics: local-only, run on user's explicit request.
umask 077
MODE="$1"
case "$MODE" in basic|extended) : ;; *) echo 'ERROR: unknown mode' >&2; exit 2 ;; esac
MODDIR="$FONTMM_DIAG_MODULE_DIR"
[ -n "$MODDIR" ] || MODDIR=/data/adb/modules/FontMM
DEST="$FONTMM_DIAG_OUTPUT_DIR"
[ -n "$DEST" ] || DEST=/storage/emulated/0/Download/FontMM
[ -d "$MODDIR" ] || { echo 'ERROR: FontMM module not found' >&2; exit 1; }
mkdir -p "$DEST" || { echo 'ERROR: unable to access Download/FontMM' >&2; exit 1; }
STAMP="$(date '+%Y%m%d-%H%M%S' 2>/dev/null)"
[ -n "$STAMP" ] || STAMP=unknown
FILE="$DEST/FontMM-diagnostics-$STAMP-$$.txt"
TMP="$FILE.tmp"
trap 'rm -f "$TMP"' 0
: > "$TMP" || { echo 'ERROR: cannot create report' >&2; exit 1; }
section() { printf '\n==== %s ====\n' "$1"; }
prop() {
  value="$(getprop "$2" 2>/dev/null)"
  printf '%s: %s\n' "$1" "$value"
}
slot() {
  if [ -s "$MODDIR/FONTS/$1.ttf" ]; then
    size="$(wc -c < "$MODDIR/FONTS/$1.ttf" | tr -d ' ')"
    printf '%s: present (%s bytes)\n' "$1" "$size"
  else printf '%s: not configured\n' "$1"; fi
}
preview() {
  if [ -f "$1" ]; then tail -n "$2" "$1" 2>/dev/null | cut -c 1-500
  else echo '(not recorded)'; fi
}
(
  echo 'FontMM HyperOS 4 diagnostic report'
  echo 'Local export only. Review content before sharing.'
  echo "Mode: $MODE"
  echo "Collected: $(date '+%Y-%m-%d %H:%M:%S %z' 2>/dev/null)"
  section 'Device (allowlisted ROM properties)'
  prop 'Android SDK' ro.build.version.sdk
  prop 'Android version' ro.build.version.release
  prop 'HyperOS version' ro.mi.os.version.name
  prop 'Build' ro.build.version.incremental
  prop 'Model' ro.product.model
  prop 'Architecture' ro.product.cpu.abi
  section 'FontMM module'
  if [ -f "$MODDIR/module.prop" ]; then
    sed -n '/^id=/p;/^name=/p;/^version=/p;/^versionCode=/p' "$MODDIR/module.prop" | head -n 8
  fi
  for resource in zygisk/arm64-v8a.so tools/fontmm-subset tools/fontmm-wght; do
    if [ -f "$MODDIR/$resource" ]; then echo "$resource: present"
    else echo "$resource: missing"; fi
  done
  if [ -f /data/adb/metamodule/module.prop ]; then echo 'KernelSU metamodule: present'
  else echo 'KernelSU metamodule: not detected'; fi
  for provider in zygisksu rezygisk; do
    if [ -f "/data/adb/modules/$provider/module.prop" ]; then
      if [ -f "/data/adb/modules/$provider/disable" ]; then echo "$provider: disabled"
      else echo "$provider: installed"; fi
    fi
  done
  section 'Font slots (file contents NOT exported)'
  for name in hans hant en mono emoji; do slot "$name"; done
  if [ -f "$MODDIR/FONTS/.en-subset.ttf" ]; then echo 'English subset: present'
  else echo 'English subset: absent'; fi
  if [ -f "$MODDIR/FONTS/.hans-no-latin.ttf" ]; then echo 'Chinese non-Latin subset: present'
  else echo 'Chinese non-Latin subset: absent'; fi
  section 'Latest font application'
  preview "$MODDIR/hyperos/last-apply.log" 220
  section 'Previous font application'
  preview "$MODDIR/hyperos/previous-apply.log" 70
  section 'Font overlay status'
  preview "$MODDIR/hyperos/apply-status.txt" 120
  section 'Installer status'
  preview "$MODDIR/hyperos/install-status.txt" 70
  section 'ROM font targets and staged overlays'
  for dir in /system/fonts /product/fonts /system_ext/fonts; do
    for name in MiSansVF.ttf MiSansLatinVF.ttf MiSansL3.otf Roboto-Regular.ttf RobotoFlex-Regular.ttf SourceSansPro-Regular.ttf; do
      target="$dir/$name"
      if [ -f "$target" ] || [ -L "$target" ]; then
        case "$dir" in
          /system/fonts) overlay="$MODDIR/system/fonts/$name" ;;
          /product/fonts) overlay="$MODDIR/system/product/fonts/$name" ;;
          /system_ext/fonts) overlay="$MODDIR/system/system_ext/fonts/$name" ;;
        esac
        if [ -f "$overlay" ]; then echo "$target: staged"
        else echo "$target: not staged"; fi
      fi
    done
  done
  if [ "$MODE" = extended ]; then
    section 'Optional font-related logcat (MAY CONTAIN PRIVATE INFORMATION)'
    if command -v logcat >/dev/null 2>&1; then
      logcat -d -t 1500 -v threadtime 2>/dev/null |
        grep -iE 'fontmm|typeface|fontmanager|MiSans|minikin|skia|fonts[.]xml|[.]ttf|[.]otf' |
        tail -n 160 | cut -c 1-500 || true
    else echo '(logcat unavailable)'; fi
  else
    section 'System logcat'
    echo 'Not collected in basic mode.'
  fi
) >> "$TMP" 2>/dev/null
[ -s "$TMP" ] || { echo 'ERROR: empty report' >&2; exit 1; }
mv -f "$TMP" "$FILE" || { echo 'ERROR: save failed' >&2; exit 1; }
chmod 0644 "$FILE" 2>/dev/null || true
printf 'DIAG_FILE=%s\n' "$FILE"
