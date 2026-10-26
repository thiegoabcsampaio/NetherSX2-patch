#!/usr/bin/env python3
"""Manifest + apktool.yml changes. Aborts if any anchor is missing.

 - targetSdk 32 -> TARGET_SDK (Play Protect "built for an older Android" block)
 - versionCode / versionName bump
 - usesCleartextTraffic true -> false + networkSecurityConfig (HTTPS only for the Java stack;
   native libcurl traffic such as RetroAchievements is not governed by it)
 - explicit dataExtractionRules / fullBackupContent (allowBackup stays true; nothing is excluded)
 - enableOnBackInvokedCallback=false keeps the legacy back behaviour on API 33+
INTERNET is intentionally kept: libemucore.so uses it (RetroAchievements, online play) and
URLDownloader fetches covers from user-defined URLs.
"""
import os
import re
import sys

root = sys.argv[1]


def sub(path, old, new, regex=False):
    p = os.path.join(root, path)
    s = open(p, encoding="utf-8").read()
    if regex:
        s2, n = re.subn(old, new, s)
    else:
        n = s.count(old)
        s2 = s.replace(old, new)
    if n != 1:
        sys.exit(f"{path}: anchor {old!r} matched {n} times, expected 1")
    open(p, "w", encoding="utf-8").write(s2)


sub("AndroidManifest.xml",
    ' android:usesCleartextTraffic="true"',
    ' android:usesCleartextTraffic="false"'
    ' android:networkSecurityConfig="@xml/network_security_config"'
    ' android:dataExtractionRules="@xml/data_extraction_rules"'
    ' android:fullBackupContent="@xml/backup_rules"'
    ' android:enableOnBackInvokedCallback="false"')
sub("apktool.yml", r"targetSdkVersion: '?\d+'?", f"targetSdkVersion: {os.environ['TARGET_SDK']}", True)
sub("apktool.yml", r"versionCode: '?\d+'?", f"versionCode: {os.environ['VERSION_CODE']}", True)
sub("apktool.yml", r"versionName: .*", f"versionName: {os.environ['VERSION_NAME']}", True)
