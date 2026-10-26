#!/usr/bin/env bash
# Applies patches/ in order on build/decoded. Fails if any patch does not apply.
source "$(dirname "$0")/common.sh"
[ -d "$DECODED" ] || { echo "run decode.sh first" >&2; exit 1; }

# 1. Resource/XML overlay (new files only: v35 theme opt-out, network security config, backup rules)
cp -r "$ROOT/overlay/." "$DECODED/"

# 2. Manifest + apktool.yml edits (strict: each one aborts if its anchor is not found)
for p in "$ROOT"/patches/manifest/*.py; do
  echo "patch $(basename "$p")"
  TARGET_SDK="$TARGET_SDK" VERSION_NAME="$VERSION_NAME" VERSION_CODE="$VERSION_CODE" python3 -I "$p" "$DECODED"
done

# 3. Smali / res unified diffs (applied with patch -p1 from the decoded root)
for p in "$ROOT"/patches/smali/*.patch "$ROOT"/patches/res/*.patch; do
  [ -e "$p" ] || continue
  echo "patch $(basename "$p")"
  patch -d "$DECODED" -p1 --forward --no-backup-if-mismatch < "$p"
done
