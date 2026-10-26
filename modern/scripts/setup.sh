#!/usr/bin/env bash
# Downloads and verifies pinned inputs (original APK, apktool, API 35 framework).
source "$(dirname "$0")/common.sh"
mkdir -p "$TOOLS" "$ROOT/original"

fetch() { # file url sha
  if [ -f "$1" ] && check_sha "$1" "$3" 2>/dev/null; then echo "ok   $(basename "$1")"; return; fi
  echo "get  $(basename "$1")"
  curl -fsSL -o "$1" "$2"
  check_sha "$1" "$3" || { echo "SHA-256 mismatch for $1" >&2; rm -f "$1"; exit 1; }
}

fetch "$ORIG_APK"    "$ORIG_URL"    "$ORIG_SHA256"
fetch "$APKTOOL_JAR" "$APKTOOL_URL" "$APKTOOL_SHA256"
fetch "$FW_JAR"      "$FW_URL"      "$FW_SHA256"

command -v java >/dev/null || { echo "JDK 17+ required" >&2; exit 1; }
for t in apksigner aapt2 zipalign; do
  p="$(find_buildtool $t)"; [ -n "$p" ] && echo "tool $t -> $p" || { echo "missing $t (install Android build-tools 35+)" >&2; exit 1; }
done
