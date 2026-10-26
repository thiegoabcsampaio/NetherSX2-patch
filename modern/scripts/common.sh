#!/usr/bin/env bash
# Shared settings for the NetherSX2 modernization scripts.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${WORK:-$ROOT/build}"
TOOLS="$ROOT/tools"
DECODED="$WORK/decoded"
FW_DIR="$WORK/framework"

ORIG_APK="$ROOT/original/NetherSX2-v2.1-4248.apk"
ORIG_SHA256="a39fe9f88de54d35a39152ce4c003ec15c9dd82064cad57b0455ac1a5cd61050"
ORIG_URL="https://github.com/Trixarian/NetherSX2-patch/releases/download/2.1/NetherSX2-v2.1-4248.apk"

APKTOOL_VERSION="2.12.1"
APKTOOL_JAR="$TOOLS/apktool-$APKTOOL_VERSION.jar"
APKTOOL_URL="https://repo1.maven.org/maven2/org/apktool/apktool-cli/$APKTOOL_VERSION/apktool-cli-$APKTOOL_VERSION.jar"
APKTOOL_SHA256="4e04969072555340cab1fd44d0d8e619937d9bd0552931e29cfa870c3b71f2d3"

# API 35 framework resources, needed so aapt2 can resolve android:windowOptOutEdgeToEdgeEnforcement
FW_JAR="$TOOLS/android-all-15-robolectric-13954326.jar"
FW_URL="https://repo1.maven.org/maven2/org/robolectric/android-all/15-robolectric-13954326/android-all-15-robolectric-13954326.jar"
FW_SHA256="e17105f6c432357e6bb278a527f8e848d01fc56ccee01be77725bea23d871990"

VERSION_NAME="v2.1-4248-modern.1"
VERSION_CODE="15246"
TARGET_SDK="${TARGET_SDK:-35}"
OUT_APK="$ROOT/release/NetherSX2-$VERSION_NAME.apk"

apktool() { java -jar "$APKTOOL_JAR" "$@"; }

# Prefer Android SDK build-tools (zipalign with -P support); fall back to PATH.
find_buildtool() {
  local name="$1" dir
  if [ -n "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}" ]; then
    dir="$(ls -d "${ANDROID_HOME:-$ANDROID_SDK_ROOT}"/build-tools/* 2>/dev/null | sort -V | tail -1 || true)"
    [ -n "$dir" ] && [ -x "$dir/$name" ] && { echo "$dir/$name"; return; }
  fi
  command -v "$name" || true
}

check_sha() { echo "$2  $1" | sha256sum -c --quiet - ; }
