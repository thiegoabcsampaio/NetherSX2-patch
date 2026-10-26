#!/usr/bin/env bash
# Automatic checks on the built APK (section 5 of the project brief).
source "$(dirname "$0")/common.sh"
APK="${1:-$OUT_APK}"
fail=0; ok(){ echo "PASS $*"; }; bad(){ echo "FAIL $*"; fail=1; }
AAPT2="$(find_buildtool aapt2)"; APKSIGNER="$(find_buildtool apksigner)"; ZIPALIGN="$(find_buildtool zipalign)"

B="$("$AAPT2" dump badging "$APK" 2>/dev/null)"
echo "$B" | grep -q "targetSdkVersion:'$TARGET_SDK'"          && ok "targetSdk $TARGET_SDK"   || bad "targetSdk"
echo "$B" | grep -q "versionCode='$VERSION_CODE'"             && ok "versionCode $VERSION_CODE" || bad "versionCode"
echo "$B" | grep -q "versionName='$VERSION_NAME'"             && ok "versionName"            || bad "versionName"
echo "$B" | grep -q "name='xyz.aethersx2.android'"            && ok "package unchanged"      || bad "package"
perms="$(echo "$B" | grep -c '^uses-permission')"
[ "$perms" = 2 ] && ok "only 2 permissions (VIBRATE, INTERNET)" || bad "permissions count $perms"

S="$("$APKSIGNER" verify --verbose --print-certs "$APK" 2>&1 || true)"
echo "$S" | grep -q "v2 scheme (APK Signature Scheme v2): true" && ok "v2 signature" || bad "v2 signature"
echo "$S" | grep -q "v3 scheme (APK Signature Scheme v3): true" && ok "v3 signature" || bad "v3 signature"

python3 -I "$ROOT/scripts/align16k.py" --check "$APK" | sed 's/^/     /'
python3 -I "$ROOT/scripts/align16k.py" --check "$APK" >/dev/null && ok "libs stored + 16 KB aligned" || bad "16 KB alignment"
"$ZIPALIGN" -c -p 4 "$APK" && ok "zipalign -c (4 / page)" || bad "zipalign -c"

mkdir -p "$ROOT/docs"
if [ -d "$DECODED" ]; then
  ( cd "$WORK" && rm -rf orig-manifest && mkdir orig-manifest && \
    java -jar "$APKTOOL_JAR" d -f -s -p "$FW_DIR" -o orig-manifest "$ORIG_APK" >/dev/null 2>&1 && \
    diff -u orig-manifest/AndroidManifest.xml "$DECODED/AndroidManifest.xml" \
      | sed 's/ android:/\n  android:/g' > "$ROOT/docs/manifest.diff" || true )
  echo "     manifest diff -> docs/manifest.diff"
fi
[ "$fail" = 0 ] && echo "ALL CHECKS PASSED" || { echo "SOME CHECKS FAILED"; exit 1; }
