#!/usr/bin/env bash
# decode -> patch -> apktool b -> zipalign (16 KB) -> apksigner (v2+v3).
# Needs KEYSTORE (default: ./nethersx2-modern.jks) and KS_PASS env var; see keystore-gen.sh.
source "$(dirname "$0")/common.sh"
KEYSTORE="${KEYSTORE:-$ROOT/nethersx2-modern.jks}"
KS_ALIAS="${KS_ALIAS:-nethersx2}"
: "${KS_PASS:?set KS_PASS (keystore password)}"
[ -f "$KEYSTORE" ] || { echo "keystore not found: $KEYSTORE (run keystore-gen.sh)" >&2; exit 1; }

"$ROOT/scripts/setup.sh"
"$ROOT/scripts/decode.sh"
"$ROOT/scripts/apply-patches.sh"

mkdir -p "$ROOT/release"
UNALIGNED="$WORK/unaligned.apk"; ALIGNED="$WORK/aligned.apk"
apktool b -p "$FW_DIR" -o "$UNALIGNED" "$DECODED"

ZIPALIGN="$(find_buildtool zipalign)"
if "$ZIPALIGN" 2>&1 | grep -q -- '-P <pagesize_kb>'; then
  "$ZIPALIGN" -P 16 -f 4 "$UNALIGNED" "$ALIGNED"
else
  echo "zipalign without -P support: using align16k.py (stored .so at 16 KB)" >&2
  python3 -I "$ROOT/scripts/align16k.py" "$UNALIGNED" "$ALIGNED"
fi

rm -f "$OUT_APK" "$OUT_APK.idsig"
"$(find_buildtool apksigner)" sign --ks "$KEYSTORE" --ks-key-alias "$KS_ALIAS" \
  --ks-pass env:KS_PASS --key-pass env:KS_PASS \
  --v1-signing-enabled false --v2-signing-enabled true --v3-signing-enabled true \
  --out "$OUT_APK" "$ALIGNED"
rm -f "$OUT_APK.idsig"
(cd "$ROOT/release" && sha256sum "$(basename "$OUT_APK")" > SHA256SUMS)
echo "built $OUT_APK"
