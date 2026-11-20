#!/system/bin/sh
MODDIR="${1:-/data/adb/modules/FontMM}"
echo 'FontMM HyperOS 4 status'
getprop ro.mi.os.version.name
getprop ro.build.version.incremental
getprop ro.build.version.sdk
if [ -r "$MODDIR/hyperos/apply-status.txt" ]; then
  cat "$MODDIR/hyperos/apply-status.txt"
else
  echo 'No font application report found.'
fi
for xml in /system_ext/etc/hyper_fonts.xml /system_ext/etc/hyper_font_fallback.xml /system/etc/fonts.xml; do
  [ -e "$xml" ] || continue
  echo "ROM XML: $xml"
done
