"""Catppuccin Mocha wallpaper: crust-to-base gradient with soft mauve and blue glows."""
import math
import struct
import sys
import zlib

W, H = 1920, 1200
CRUST, BASE = (0x11, 0x11, 0x1B), (0x1E, 0x1E, 0x2E)
GLOWS = [  # (centre x, centre y, radius, colour, strength)
    (0.78 * W, 0.22 * H, 0.55 * W, (0xCB, 0xA6, 0xF7), 0.30),  # mauve
    (0.18 * W, 0.85 * H, 0.50 * W, (0x89, 0xB4, 0xFA), 0.24),  # blue
    (0.50 * W, 1.10 * H, 0.45 * W, (0xF5, 0xC2, 0xE7), 0.10),  # pink
]


def pixel(x, y):
    t = (x / W * 0.35 + y / H * 0.65)
    c = [CRUST[i] + (BASE[i] - CRUST[i]) * t for i in range(3)]
    for gx, gy, r, col, s in GLOWS:
        d = math.hypot(x - gx, y - gy) / r
        k = s * math.exp(-d * d * 2.2)
        c = [c[i] + (col[i] - c[i]) * k for i in range(3)]
    return bytes(int(min(255, v)) for v in c)


def chunk(tag, data):
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)


# Glows vary slowly: compute on a coarse grid and repeat, keeps pure Python fast
STEP = 4
rows = []
for y in range(0, H, STEP):
    line = b"".join(pixel(x, y) * STEP for x in range(0, W, STEP))
    rows.extend([b"\x00" + line] * STEP)
png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0))
png += chunk(b"IDAT", zlib.compress(b"".join(rows), 6)) + chunk(b"IEND", b"")
open(sys.argv[1], "wb").write(png)
