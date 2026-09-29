"""Generează iconița aplicației iOS (1024×1024, fără transparență).

Rulare: python3 -m pip install pillow && python3 tools/make_icon.py
Scrie ios/App/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png.

Design original „stadion nocturn”: cer întunecat, două reflectoare aurii,
gazon verde în perspectivă și o minge clasică cu panouri, cu un inel auriu.
"""
import math
import os
import sys

from PIL import Image, ImageDraw, ImageFilter

S = 1024
ROOT = os.path.join(os.path.dirname(__file__), "..")
OUT = os.path.join(ROOT, "ios", "App", "Resources", "Assets.xcassets", "AppIcon.appiconset", "AppIcon.png")

BG_TOP = (6, 12, 10)
BG_BOTTOM = (18, 38, 28)
PITCH = (31, 138, 76)
PITCH_DARK = (22, 104, 56)
GOLD = (224, 184, 75)
GOLD_LIGHT = (244, 211, 122)
WHITE = (240, 244, 240)
INK = (14, 22, 18)


def lerp(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def main(out=OUT):
    img = Image.new("RGB", (S, S))
    d = ImageDraw.Draw(img)

    # cer: gradient vertical
    for y in range(S):
        d.line([(0, y), (S, y)], fill=lerp(BG_TOP, BG_BOTTOM, y / S))

    # reflectoare: conuri de lumină aurie, estompate
    beams = Image.new("L", (S, S), 0)
    bd = ImageDraw.Draw(beams)
    for x0, dx in ((90, 1), (S - 90, -1)):
        bd.polygon([(x0, 60), (x0 + dx * 40, 40), (S // 2 + dx * 260, S), (S // 2 - dx * 60, S)], fill=70)
    beams = beams.filter(ImageFilter.GaussianBlur(40))
    img = Image.composite(Image.new("RGB", (S, S), GOLD_LIGHT), img, beams)
    d = ImageDraw.Draw(img)
    for x0 in (90, S - 90):
        d.ellipse([x0 - 34, 26, x0 + 34, 94], fill=GOLD_LIGHT)

    # gazon în perspectivă, cu dungi
    horizon = 600
    stripes = 7
    for i in range(stripes):
        y0 = horizon + (S - horizon) * (i / stripes) ** 1.3
        y1 = horizon + (S - horizon) * ((i + 1) / stripes) ** 1.3
        d.rectangle([0, y0, S, y1 + 1], fill=PITCH if i % 2 == 0 else PITCH_DARK)
    d.line([(0, horizon), (S, horizon)], fill=(200, 230, 210), width=4)

    # umbra mingii
    shadow = Image.new("L", (S, S), 0)
    ImageDraw.Draw(shadow).ellipse([S // 2 - 230, 845, S // 2 + 230, 925], fill=150)
    shadow = shadow.filter(ImageFilter.GaussianBlur(18))
    img = Image.composite(Image.new("RGB", (S, S), (0, 0, 0)), img, shadow)

    # minge: supraeșantionată pentru margini netede
    k = 4
    R = 300
    cx, cy = S // 2, 520
    ball = Image.new("RGBA", (2 * R * k + 80 * k, 2 * R * k + 80 * k), (0, 0, 0, 0))
    bdraw = ImageDraw.Draw(ball)
    bc = ball.size[0] // 2
    ring = 26 * k
    bdraw.ellipse([bc - R * k - ring, bc - R * k - ring, bc + R * k + ring, bc + R * k + ring], fill=GOLD)
    bdraw.ellipse([bc - R * k, bc - R * k, bc + R * k, bc + R * k], fill=WHITE)

    def pentagon(px, py, r, rot):
        return [(px + r * math.cos(rot + i * 2 * math.pi / 5), py + r * math.sin(rot + i * 2 * math.pi / 5)) for i in range(5)]

    rk = R * k
    center = pentagon(bc, bc, rk * 0.30, -math.pi / 2)
    bdraw.polygon(center, fill=INK)
    for i in range(5):
        a = -math.pi / 2 + i * 2 * math.pi / 5
        # cusături de la pentagonul central spre cele exterioare
        vx, vy = center[i]
        ox, oy = bc + rk * 0.62 * math.cos(a), bc + rk * 0.62 * math.sin(a)
        bdraw.line([(vx, vy), (ox, oy)], fill=INK, width=9 * k)
        bdraw.polygon(pentagon(bc + rk * 0.86 * math.cos(a), bc + rk * 0.86 * math.sin(a), rk * 0.25, a + math.pi), fill=INK)
        b2 = a + math.pi / 5
        vx2, vy2 = bc + rk * 0.62 * math.cos(b2 - math.pi / 5), bc + rk * 0.62 * math.sin(b2 - math.pi / 5)
        wx, wy = bc + rk * 0.62 * math.cos(b2 + math.pi / 5), bc + rk * 0.62 * math.sin(b2 + math.pi / 5)
        bdraw.line([(vx2, vy2), (wx, wy)], fill=INK, width=9 * k)
    # decupăm tot ce iese din cercul alb (pentagoanele exterioare)
    mask = Image.new("L", ball.size, 0)
    ImageDraw.Draw(mask).ellipse([bc - rk, bc - rk, bc + rk, bc + rk], fill=255)
    white_layer = Image.new("RGBA", ball.size, (0, 0, 0, 0))
    white_layer.paste(ball, (0, 0), mask)
    ring_layer = Image.new("RGBA", ball.size, (0, 0, 0, 0))
    rd = ImageDraw.Draw(ring_layer)
    rd.ellipse([bc - rk - ring, bc - rk - ring, bc + rk + ring, bc + rk + ring], fill=GOLD)
    rd.ellipse([bc - rk - ring + 6 * k, bc - rk - ring + 6 * k, bc + rk + ring - 6 * k, bc + rk + ring - 6 * k], fill=GOLD_LIGHT)
    ring_layer.alpha_composite(white_layer)
    # luciu
    gloss = Image.new("L", ball.size, 0)
    ImageDraw.Draw(gloss).ellipse([bc - rk * 0.62, bc - rk * 0.86, bc + rk * 0.1, bc - rk * 0.3], fill=70)
    gloss = gloss.filter(ImageFilter.GaussianBlur(30 * k))
    ring_layer.paste(Image.new("RGBA", ball.size, (255, 255, 255, 255)), (0, 0), Image.composite(gloss, Image.new("L", ball.size, 0), mask))

    small = ring_layer.resize((ball.size[0] // k, ball.size[1] // k), Image.LANCZOS)
    img.paste(small, (cx - small.size[0] // 2, cy - small.size[1] // 2), small)

    os.makedirs(os.path.dirname(out), exist_ok=True)
    img.save(out, "PNG", optimize=True)
    print(out, os.path.getsize(out), "bytes")


if __name__ == "__main__":
    main(*sys.argv[1:])
