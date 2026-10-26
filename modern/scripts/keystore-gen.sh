#!/usr/bin/env bash
# Creates a local RSA-4096 keystore (valid ~27 years). NEVER commit it.
source "$(dirname "$0")/common.sh"
KEYSTORE="${KEYSTORE:-$ROOT/nethersx2-modern.jks}"
KS_ALIAS="${KS_ALIAS:-nethersx2}"
: "${KS_PASS:?set KS_PASS (keystore password, min 6 chars)}"
[ -e "$KEYSTORE" ] && { echo "$KEYSTORE already exists" >&2; exit 1; }
keytool -genkeypair -keystore "$KEYSTORE" -alias "$KS_ALIAS" -keyalg RSA -keysize 4096 \
  -validity 10000 -storepass:env KS_PASS -keypass:env KS_PASS \
  -dname "CN=NetherSX2 Modern, O=NetherSX2-patch"
echo "created $KEYSTORE - back it up; losing it means users cannot update in place"
