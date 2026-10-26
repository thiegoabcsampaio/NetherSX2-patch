#!/usr/bin/env bash
# Decodes the original APK into build/decoded (the original is never modified).
source "$(dirname "$0")/common.sh"
check_sha "$ORIG_APK" "$ORIG_SHA256" || { echo "Original APK SHA-256 mismatch, aborting" >&2; exit 1; }
rm -rf "$DECODED" "$FW_DIR"; mkdir -p "$WORK" "$FW_DIR"
apktool if -p "$FW_DIR" "$FW_JAR" >/dev/null
apktool d -f -p "$FW_DIR" -o "$DECODED" "$ORIG_APK"
