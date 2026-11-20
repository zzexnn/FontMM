#!/system/bin/sh
# HyperOS4 native font filename overlay using existing FontMM FONTS/.
# No raw partition writes, custom mount operations, /data font cache deletion,
# unsafe XML edits, or global SELinux changes.

MODDIR="${1:-/data/adb/modules/FontMM}"
FONTS="$MODDIR/FONTS"
[ -s "$FONTS/hans.ttf" ] || { echo '[HOS4] Missing Simplified Chinese font'; exit 1; }

# Test injection only: allows a mock ROM directory in static automated tests.
DEVROOT="${FONTMM_TEST_SYSTEM_ROOT:-}"

# Names are drawn from HyperOS/Android font layouts. A file is touched ONLY
# when the corresponding original Android system font exists on the device.
# Never replace .ttc collections with a single .ttf (collection index mismatch).
HANS_NAMES='MiSansVF.ttf MiSansVF_Overlay.ttf MiSansL3.otf MiSans-Regular.ttf MiSans-Light.ttf MiSans-Medium.ttf MiSans-Bold.ttf MiSansSCVF.ttf MiSansCNVF.ttf NotoSansSC-Regular.ttf NotoSansCJKsc-Regular.otf'
HANT_NAMES='MiSansTCVF.ttf MiSansTC-Regular.ttf MiSansTC-Medium.ttf MiSansTC-Bold.ttf NotoSansTC-Regular.ttf NotoSansCJKtc-Regular.otf'
EN_NAMES='MiSansLatinVF.ttf MiSansLatin-Regular.ttf MiSansLatin-Medium.ttf MiSansLatin-Bold.ttf Roboto-Regular.ttf Roboto-Medium.ttf Roboto-Bold.ttf Roboto-Light.ttf Roboto-Thin.ttf Roboto-Black.ttf Roboto-Italic.ttf Roboto-BoldItalic.ttf RobotoFlex-Regular.ttf RobotoStatic-Regular.ttf RobotoCondensed-Regular.ttf RobotoCondensed-Bold.ttf'
MONO_NAMES='DroidSansMono.ttf RobotoMono-Regular.ttf'
EMOJI_NAMES='NotoColorEmoji.ttf'

# Original FontMM may have created a Latin-only subset; prefer that file to
# avoid letting the English slot cover Han glyphs.
EN_SRC="$FONTS/en.ttf"
[ -s "$EN_SRC" ] || EN_SRC="$FONTS/hans.ttf"
[ -s "$FONTS/.en-subset.ttf" ] && [ -s "$FONTS/en.ttf" ] && EN_SRC="$FONTS/.en-subset.ttf"
HANT_SRC="$FONTS/hant.ttf"; [ -s "$HANT_SRC" ] || HANT_SRC="$FONTS/hans.ttf"

COUNTER=0
ERRORS=0
STATUS="$MODDIR/hyperos/apply-status.txt"
mkdir -p "$MODDIR/hyperos" || exit 1
: > "$STATUS" || exit 1

# Do not blindly create nonexistent system fonts (that risks overlaying a
# directory with irrelevant entries and masks ROM-specific differences).
stage() {
  src="$1"; logical="$2"; name="$3"; slot="$4"
  [ -s "$src" ] || return 0
  case "$logical" in
    system) real="$DEVROOT/system/fonts/$name"; dest="$MODDIR/system/fonts/$name" ;;
    product) real="$DEVROOT/product/fonts/$name"; dest="$MODDIR/system/product/fonts/$name" ;;
    system_ext) real="$DEVROOT/system_ext/fonts/$name"; dest="$MODDIR/system/system_ext/fonts/$name" ;;
    *) return 0 ;;
  esac
  [ -f "$real" ] || [ -L "$real" ] || return 0
  mkdir -p "${dest%/*}" || return 1
  tmp="$dest.hos4-tmp.$$"
  rm -f "$tmp"
  # Hard links avoid needless duplication of 20-30MB font files. Fall back
  # to a normal copy if filesystem semantics disallow linking.
  ln "$src" "$tmp" 2>/dev/null || cp -f "$src" "$tmp" || return 1
  chmod 0644 "$tmp" 2>/dev/null
  # BusyBox/Toybox mv rejects two hardlinks of the same inode as "same file"
  # on a second Apply. The source temp link is ready, then replace the alias.
  rm -f "$dest" || { rm -f "$tmp"; return 1; }
  mv -f "$tmp" "$dest" || { rm -f "$tmp"; return 1; }
  COUNTER=$((COUNTER+1))
  printf '%s %s %s\n' "$slot" "$logical" "$name" >> "$STATUS"
  echo "[HOS4] $slot -> /$logical/fonts/$name"
  return 0
}

stage_list() {
  font="$1"; slot="$2"; names="$3"
  for name in $names; do
    case "$name" in
      *.ttf|*.otf) : ;;
      *) continue ;;
    esac
    for logical in system product system_ext; do
      stage "$font" "$logical" "$name" "$slot" || ERRORS=$((ERRORS+1))
    done
  done
}

stage_list "$FONTS/hans.ttf" hans "$HANS_NAMES"
stage_list "$HANT_SRC" hant "$HANT_NAMES"
stage_list "$EN_SRC" en "$EN_NAMES"
[ -s "$FONTS/mono.ttf" ] && stage_list "$FONTS/mono.ttf" mono "$MONO_NAMES"
[ -s "$FONTS/emoji.ttf" ] && stage_list "$FONTS/emoji.ttf" emoji "$EMOJI_NAMES"

if [ "$ERRORS" -gt 0 ]; then
  echo "[HOS4] ERROR: $ERRORS files could not be staged; check storage."
  exit 1
fi
if [ "$COUNTER" -eq 0 ]; then
  echo '[HOS4] ERROR: No matching original HyperOS font files discovered.'
  echo '[HOS4] No system changes were made; old FontMM configuration remains safe.'
  exit 1
fi
printf 'total=%s\n' "$COUNTER" >> "$STATUS"
echo "[HOS4] Prepared $COUNTER OEM font overlays. Reboot for changes to take effect."
if [ "$(cat "$FONTS/wght-mode.txt" 2>/dev/null)" != '0' ] && [ -s "$FONTS/wght-mode.txt" ]; then
  echo '[HOS4] NOTE: FontMM advanced custom wght XML mapping is not applied to HyperOS OEM XML.'
  echo '[HOS4] Variable wght support depends on your font file and native HyperOS font mapping.'
fi
exit 0
