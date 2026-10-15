"""320x180 battle backdrops per stage (shown at 2x in engine) + title portal."""
import random, math
from PIL import Image
from pxlib import hx

W, H = 320, 180
BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3)) + (255,)


def grad(px, y0, y1, cols, x0=0, x1=W):
    """banded vertical gradient through a list of colours with Bayer dither between bands"""
    n = len(cols) - 1
    for y in range(y0, y1):
        t = (y - y0) / max(1, (y1 - y0 - 1)) * n
        i = min(n - 1, int(t)); f = t - i
        for x in range(x0, x1):
            th = (BAYER[y % 4][x % 4] + 0.5) / 16
            px[x, y] = hx(cols[i + 1]) if f > th else hx(cols[i])


def stage1():
    rnd = random.Random(11)
    img = Image.new('RGBA', (W, H)); px = img.load()
    grad(px, 0, 110, ['#05060e', '#0c1024', '#1a1c3a', '#2a2244'])
    # moon
    for y in range(12, 34):
        for x in range(250, 272):
            if (x - 261) ** 2 + (y - 23) ** 2 <= 100:
                px[x, y] = hx('#e8e0c0') if (x - 258) ** 2 + (y - 20) ** 2 > 30 or True else 0
    for y in range(12, 34):
        for x in range(250, 272):
            if (x - 265) ** 2 + (y - 20) ** 2 <= 70 and (x - 261) ** 2 + (y - 23) ** 2 <= 100:
                px[x, y] = hx('#b8ae90')
    for _ in range(40):
        px[rnd.randrange(W), rnd.randrange(70)] = hx('#6a6a9a')
    # far skyline
    x = 0
    while x < W:
        bw = rnd.randint(18, 40); bh = rnd.randint(30, 70)
        for yy in range(110 - bh, 110):
            for xx in range(x, min(W, x + bw)):
                px[xx, yy] = hx('#10122a')
        for wy in range(110 - bh + 4, 106, 6):
            for wx in range(x + 3, x + bw - 3, 5):
                if rnd.random() < 0.25 and wx < W:
                    px[wx, wy] = hx('#c8a040'); px[min(W - 1, wx + 1), wy] = hx('#c8a040')
        x += bw + rnd.randint(0, 4)
    # brick wall
    for y in range(110, 150):
        for x in range(W):
            row = (y - 110) // 6
            off = 0 if row % 2 == 0 else 7
            mortar = (y - 110) % 6 == 0 or (x + off) % 14 == 0
            c = '#1c1622' if mortar else ('#3a2230' if (x // 14 + row) % 3 else '#33202a')
            px[x, y] = hx(c)
    # graffiti blobs
    for (gx, gy, col) in ((40, 124, '#3a8a8a'), (180, 130, '#8a2a5a')):
        for k in range(26):
            px[gx + k, gy + int(3 * math.sin(k / 3))] = hx(col)
            px[gx + k, gy + 1 + int(3 * math.sin(k / 3))] = hx(col)
    # ground asphalt
    grad(px, 150, 180, ['#18182a', '#101020', '#0a0a14'])
    for _ in range(200):
        px[rnd.randrange(W), rnd.randrange(150, 180)] = hx('#24243a')
    # puddles
    for (cx, cy, r) in ((90, 166, 22), (240, 172, 30)):
        for y in range(cy - 3, cy + 4):
            for x in range(cx - r, cx + r):
                if ((x - cx) / r) ** 2 + ((y - cy) / 3.5) ** 2 <= 1 and 0 <= x < W and y < H:
                    px[x, y] = hx('#1e2a48') if (x + y) % 3 else hx('#3a4a78')
    # street lamp light cone (dithered)
    lx = 270
    for y in range(40, 180):
        half = (y - 40) * 0.35
        for x in range(int(lx - half), int(lx + half)):
            if 0 <= x < W:
                t = 1 - abs(x - lx) / max(1, half)
                if (BAYER[y % 4][x % 4] / 16) < t * 0.35:
                    r, g, b, a = px[x, y]
                    px[x, y] = (min(255, r + 40), min(255, g + 32), min(255, b + 8), 255)
    for y in range(30, 150):
        px[lx + 12, y] = hx('#0a0a10'); px[lx + 13, y] = hx('#1a1a26')
    for x in range(lx - 2, lx + 14):
        px[x, 30] = hx('#1a1a26')
    for x in range(lx - 4, lx + 4):
        px[x, 31] = hx('#ffe080'); px[x, 32] = hx('#c8a040')
    return img


def stage2():
    rnd = random.Random(22)
    img = Image.new('RGBA', (W, H)); px = img.load()
    grad(px, 0, 120, ['#0a0204', '#1e050a', '#3a0a0e', '#6a1a0c'])
    # jagged rocks back
    for layer, col, base in ((0, '#1a060a', 120), (1, '#0e0306', 132)):
        x = 0; h = 40
        while x < W:
            h = max(10, min(80, h + rnd.randint(-12, 12)))
            w = rnd.randint(4, 10)
            for xx in range(x, min(W, x + w)):
                peak = base - h + abs(xx - x - w // 2)
                for yy in range(max(0, peak), base + 10):
                    px[xx, yy] = hx(col)
            x += w
    # lava river horizon
    for y in range(128, 140):
        for x in range(W):
            wv = math.sin(x / 9 + y) * 0.5 + 0.5
            px[x, y] = hx('#ffb030') if wv > 0.8 and y < 132 else hx('#e04a10') if wv > 0.35 else hx('#8a1406')
    # ground obsidian
    grad(px, 140, 180, ['#160608', '#0c0305', '#050102'])
    for _ in range(14):
        x, y = rnd.randrange(W), rnd.randrange(142, 178)
        for k in range(rnd.randint(6, 18)):
            if 0 <= x < W and y < H:
                px[x, y] = hx('#c0360c') if k % 3 else hx('#ffb030')
            x += rnd.choice((-1, 1, 1)); y += rnd.choice((0, 0, 1))
    # chains
    for cx in (60, 200):
        for y in range(0, 70, 3):
            px[cx, y] = hx('#3a3a4c'); px[cx + 1, y + 1] = hx('#62627a')
    # embers
    for _ in range(60):
        px[rnd.randrange(W), rnd.randrange(130)] = hx('#ff8a30') if rnd.random() < .5 else hx('#ffd060')
    return img


def stage3():
    rnd = random.Random(33)
    img = Image.new('RGBA', (W, H)); px = img.load()
    grad(px, 0, 180, ['#12040a', '#2a0a16', '#4a1424', '#2a0a14', '#16050a'])
    # fleshy wall lumps
    for _ in range(26):
        cx, cy, r = rnd.randrange(W), rnd.randrange(0, 140), rnd.randint(10, 28)
        for y in range(cy - r, cy + r):
            for x in range(cx - r, cx + r):
                if 0 <= x < W and 0 <= y < H:
                    d = ((x - cx) ** 2 + (y - cy) ** 2) / (r * r)
                    if d <= 1:
                        lx = (x - cx + r * 0.4) ** 2 + (y - cy + r * 0.4) ** 2
                        c = '#6a2232' if d > 0.75 else '#86283e'
                        if lx < r * r * 0.12:
                            c = '#a83c4a'
                        px[x, y] = hx(c)
    # veins
    for _ in range(9):
        x, y = rnd.randrange(W), rnd.randrange(140)
        for k in range(120):
            if 0 <= x < W and 0 <= y < H:
                px[x, y] = hx('#3a0820')
            x += rnd.choice((-1, 0, 1, 1)); y += rnd.choice((-1, 0, 1, 1))
    # wall eyes
    for _ in range(7):
        cx, cy = rnd.randrange(10, W - 10), rnd.randrange(15, 120)
        for y in range(cy - 3, cy + 4):
            for x in range(cx - 5, cx + 6):
                if ((x - cx) / 5.5) ** 2 + ((y - cy) / 3.2) ** 2 <= 1:
                    px[x, y] = hx('#f0eaf2')
        for (x, y) in ((cx, cy), (cx + 1, cy), (cx, cy - 1), (cx + 1, cy - 1)):
            px[x, y] = hx('#7a1840')
        px[cx, cy] = hx('#140c1c')
    # floor membrane
    grad(px, 145, 180, ['#3a0e1c', '#260812', '#14040a'])
    for _ in range(20):
        cx, cy = rnd.randrange(W), rnd.randrange(150, 178)
        for x in range(cx - 4, cx + 5):
            for y in range(cy - 2, cy + 2):
                if 0 <= x < W and y < H and ((x - cx) / 4.5) ** 2 + ((y - cy) / 2) ** 2 <= 1:
                    px[x, y] = hx('#d2c242') if y < cy else hx('#8a7a18')
    # hanging tendrils
    for cx in range(10, W, 37):
        L = rnd.randint(14, 40)
        for y in range(L):
            x = cx + int(2 * math.sin(y / 5))
            px[x, y] = hx('#a43a48'); px[x + 1, y] = hx('#66202e')
    return img


def title_portal():
    img = Image.new('RGBA', (W, H)); px = img.load()
    grad(px, 0, H, ['#05030a', '#0e0718', '#140a22', '#0a0512'])
    cx, cy = 160, 78
    cols = ['#14081f', '#3a1858', '#66329c', '#9c5cd4', '#c64c98', '#ffd8f0']
    for y in range(H):
        for x in range(W):
            dx, dy = (x - cx) / 1.0, (y - cy) / 0.62
            r = math.hypot(dx, dy)
            a = math.atan2(dy, dx)
            sw = r + 10 * math.sin(a * 3 + r / 9)
            if r < 70:
                band = int((70 - r) / 12 + (math.sin(sw / 6) * 0.8))
                band = max(0, min(len(cols) - 1, band))
                th = (BAYER[y % 4][x % 4] + .5) / 16
                if r > 62 and th > (70 - r) / 8:
                    continue
                px[x, y] = hx(cols[band])
    rnd = random.Random(4)
    for _ in range(90):
        px[rnd.randrange(W), rnd.randrange(H)] = hx('#5a4a78')
    # ground
    grad(px, 140, 180, ['#0c0814', '#06040a'])
    return img


BGS = {'bg_s1': stage1, 'bg_s2': stage2, 'bg_s3': stage3, 'bg_title': title_portal}
