#!/usr/bin/env python3
"""Fallback for zipalign < 35 (no -P): align stored .so to 16 KB and other stored entries to 4 bytes.

Usage: align16k.py in.apk out.apk
"""
import struct
import sys
import zipfile

SO_ALIGN, ALIGN = 16384, 4


def pad_extra(offset, name, extra, align):
    data_start = offset + 30 + len(name.encode()) + len(extra)
    pad = (-data_start) % align
    if pad == 0:
        return extra
    while pad < 4:  # an extra field needs a 4-byte header
        pad += align
    return extra + struct.pack("<HH", 0xD935, pad - 4) + b"\0" * (pad - 4)


def main(src, dst):
    with zipfile.ZipFile(src) as zin, zipfile.ZipFile(dst, "w") as zout:
        for info in zin.infolist():
            data = zin.read(info)
            new = zipfile.ZipInfo(info.filename, info.date_time)
            new.compress_type = info.compress_type
            new.external_attr = info.external_attr
            new.create_system = info.create_system
            extra = b""
            if info.compress_type == zipfile.ZIP_STORED:
                align = SO_ALIGN if info.filename.endswith(".so") else ALIGN
                extra = pad_extra(zout.fp.tell(), info.filename, b"", align)
            new.extra = extra
            zout.writestr(new, data, compresslevel=9)


def check(path):
    bad = []
    with zipfile.ZipFile(path) as z:
        for i in z.infolist():
            if i.compress_type == zipfile.ZIP_STORED and i.filename.endswith(".so"):
                with open(path, "rb") as f:
                    f.seek(i.header_offset + 26)
                    n, m = struct.unpack("<HH", f.read(4))
                start = i.header_offset + 30 + n + m
                if start % SO_ALIGN:
                    bad.append((i.filename, start % SO_ALIGN))
            elif i.filename.endswith(".so"):
                bad.append((i.filename, "compressed"))
    return bad


if __name__ == "__main__":
    if sys.argv[1] == "--check":
        b = check(sys.argv[2])
        print("16KB .so alignment:", "OK" if not b else f"FAIL {b}")
        sys.exit(1 if b else 0)
    main(sys.argv[1], sys.argv[2])
