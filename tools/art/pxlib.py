"""Tiny pixel-art canvas with region-based auto shading + selective outline.

Rules followed (pixel-art-professional / pixel-art skill):
  * limited, hue-shifted ramps (shadow -> cool, highlight -> warm)
  * single light source from top-left, no pillow shading
  * selective (coloured) outline instead of pure black
  * every sprite rendered at 1x; engine scales with integer factors only
"""
from PIL import Image, ImageDraw
import math, os

def hx(c):
    c = c.lstrip('#')
    if len(c) == 6:
        return (int(c[0:2], 16), int(c[2:4], 16), int(c[4:6], 16), 255)
    return (int(c[0:2], 16), int(c[2:4], 16), int(c[4:6], 16), int(c[6:8], 16))

# ramp = [outline, shadow, base, highlight]
RAMPS = {
    'skin':    ['#4a2228', '#b8664e', '#eaa882', '#ffd8b0'],
    'skin2':   ['#3a1c1c', '#7e4634', '#b4734e', '#d89a6c'],
    'pale':    ['#33303e', '#8f8a94', '#c9c3bd', '#ece6dc'],
    'zomb':    ['#1e2a1e', '#4e6a48', '#7a9a6a', '#a8c48c'],
    'hair':    ['#07060c', '#16131f', '#2a2536', '#4a4462'],
    'hairbr':  ['#200f0a', '#4a2616', '#7a4426', '#a86a3a'],
    'white':   ['#34364c', '#a3abc0', '#dfe3ec', '#ffffff'],
    'grey':    ['#16172a', '#3a3e58', '#5c6282', '#868eae'],
    'red':     ['#2a0814', '#6e1424', '#b02a32', '#e85a42'],
    'black':   ['#050409', '#121019', '#24202e', '#3c3650'],
    'denim':   ['#0c1230', '#22345e', '#3a5890', '#5f86bf'],
    'olive':   ['#121608', '#2e3a18', '#4e5e26', '#74883a'],
    'metal':   ['#181b28', '#4a5266', '#8c95a8', '#d4dae4'],
    'wood':    ['#24130a', '#5a3519', '#8c5c2c', '#bc8a42'],
    'gold':    ['#361e06', '#8a5a12', '#dca424', '#ffe86a'],
    'orange':  ['#381004', '#8a3410', '#da661e', '#ffa848'],
    'yellow':  ['#3a2806', '#9c7a10', '#e8c42a', '#fff47e'],
    'green':   ['#0a200e', '#1d5226', '#388a3c', '#7ec45c'],
    'teal':    ['#08202a', '#155058', '#2a8a8a', '#62c8b8'],
    'blue':    ['#0a0e2c', '#1d2e70', '#3658bc', '#6c92ea'],
    'purple':  ['#14081f', '#3a1858', '#66329c', '#9c5cd4'],
    'demon':   ['#200410', '#5c0e1c', '#a01e26', '#dc4a3a'],
    'imp':     ['#18061c', '#4a1240', '#86246c', '#c64c98'],
    'cloth':   ['#3a3646', '#a6a096', '#dedac8', '#fdfaef'],
    'shadow':  ['#000000', '#0a0711', '#1a1428', '#2e2446'],
    'flesh':   ['#36091a', '#86283e', '#cc5a6a', '#f4a0a0'],
    'flesh2':  ['#26080f', '#66202e', '#a43a48', '#d8686a'],
    'pus':     ['#362e08', '#8a7a18', '#d2c242', '#f8f08e'],
    'bone':    ['#362c22', '#8c7c60', '#d2c6a2', '#f6eed4'],
    'slime':   ['#0c260e', '#2a6a26', '#5ca83c', '#a8e272'],
    'vein':    ['#160310', '#460a28', '#7a1840', '#b23262'],
    'eye':     ['#3a2a3a', '#b8a8bc', '#f0eaf2', '#ffffff'],
    'brown':   ['#1c1008', '#4a2e1a', '#7c502e', '#aa784c'],
    'khaki':   ['#262010', '#5e5230', '#968660', '#c6b68a'],
    'fire':    ['#3a0a04', '#c0360c', '#f48c1c', '#ffe060'],
    'lava':    ['#2a0404', '#8a1406', '#e04a10', '#ffb030'],
    'glass':   ['#1a2a38', '#4a7a98', '#8ac4dc', '#e0f6ff'],
    'paper':   ['#3a3428', '#a8a088', '#e4dcc0', '#fffbe8'],
    'pink':    ['#3a0a24', '#9a2a5a', '#e0609a', '#ffa8cc'],
    'rust':    ['#1e0c06', '#5a2810', '#9a4a1e', '#c87a3a'],
    'stone':   ['#141420', '#3a3a4c', '#62627a', '#9090a8'],
    'navy':    ['#060814', '#121a36', '#22305a', '#3a4c82'],
}

def ramp(name, i):
    return hx(RAMPS[name][i])

class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.rid = [[-1] * w for _ in range(h)]
        self.regions = []          # dict(mat, shade, edge, z)
        self.detail = {}           # (x,y) -> rgba  (final colours, drawn on top)
        self.post = []             # callables(img)

    # ---------------- region helpers -----------------
    def _new(self, mat, shade, edge):
        self.regions.append(dict(mat=mat, shade=shade, edge=edge, z=len(self.regions)))
        return len(self.regions) - 1

    def _apply_mask(self, mask, mat, shade, edge, clip=None):
        r = self._new(mat, shade, edge)
        px = mask.load()
        for y in range(self.h):
            for x in range(self.w):
                if px[x, y]:
                    if clip is not None and self.rid[y][x] not in clip:
                        continue
                    self.rid[y][x] = r
        return r

    def _mask(self):
        return Image.new('L', (self.w, self.h), 0)

    def ellipse(self, cx, cy, rx, ry, mat, shade='sphere', edge=False, clip=None):
        m = self._mask(); px = m.load()
        for y in range(self.h):
            for x in range(self.w):
                dx = (x + 0.5 - cx) / rx
                dy = (y + 0.5 - cy) / ry
                if dx * dx + dy * dy <= 1.0:
                    px[x, y] = 255
        return self._apply_mask(m, mat, shade, edge, clip)

    def rect(self, x, y, w, h, mat, shade='edge', edge=False, clip=None):
        m = self._mask(); d = ImageDraw.Draw(m)
        d.rectangle([x, y, x + w - 1, y + h - 1], fill=255)
        return self._apply_mask(m, mat, shade, edge, clip)

    def rrect(self, x, y, w, h, mat, shade='edge', edge=False, clip=None):
        """rectangle with 1px chamfered corners"""
        m = self._mask(); d = ImageDraw.Draw(m)
        d.rectangle([x, y, x + w - 1, y + h - 1], fill=255)
        for cx, cy in ((x, y), (x + w - 1, y), (x, y + h - 1), (x + w - 1, y + h - 1)):
            m.putpixel((cx, cy), 0)
        return self._apply_mask(m, mat, shade, edge, clip)

    def poly(self, pts, mat, shade='edge', edge=False, clip=None):
        m = self._mask(); d = ImageDraw.Draw(m)
        d.polygon(pts, fill=255, outline=255)
        return self._apply_mask(m, mat, shade, edge, clip)

    def line(self, pts, mat, width=1, shade='flat', edge=False):
        m = self._mask(); d = ImageDraw.Draw(m)
        d.line(pts, fill=255, width=width)
        return self._apply_mask(m, mat, shade, edge)

    def pixels(self, pts, mat, shade='flat', edge=False):
        m = self._mask()
        for (x, y) in pts:
            if 0 <= x < self.w and 0 <= y < self.h:
                m.putpixel((x, y), 255)
        return self._apply_mask(m, mat, shade, edge)

    def stamp(self, ox, oy, rows, legend, shade='flat', edge=False):
        """ASCII stamp. legend: char -> material name (region) or '#rrggbb' (detail)."""
        groups = {}
        for j, row in enumerate(rows):
            for i, ch in enumerate(row):
                if ch in (' ', '.'):
                    continue
                v = legend.get(ch)
                if v is None:
                    continue
                x, y = ox + i, oy + j
                if not (0 <= x < self.w and 0 <= y < self.h):
                    continue
                if v.startswith('#'):
                    self.detail[(x, y)] = hx(v)
                elif v == 'ERASE':
                    self.rid[y][x] = -1
                    self.detail.pop((x, y), None)
                else:
                    groups.setdefault(v, []).append((x, y))
        for mat, pts in groups.items():
            self.pixels(pts, mat, shade=shade, edge=edge)

    def erase_rect(self, x, y, w, h):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                if 0 <= xx < self.w and 0 <= yy < self.h:
                    self.rid[yy][xx] = -1

    def erase_px(self, pts):
        for (x, y) in pts:
            if 0 <= x < self.w and 0 <= y < self.h:
                self.rid[y][x] = -1
                self.detail.pop((x, y), None)

    def dot(self, x, y, col):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.detail[(x, y)] = hx(col) if isinstance(col, str) else col

    def dots(self, pts, col):
        for p in pts:
            self.dot(p[0], p[1], col)

    # ---------------- render -----------------
    def _inside(self, x, y, r):
        return 0 <= x < self.w and 0 <= y < self.h and self.rid[y][x] == r

    def render(self, outline=True, light=(-0.62, -0.78)):
        img = Image.new('RGBA', (self.w, self.h), (0, 0, 0, 0))
        px = img.load()
        # bbox per region for sphere shading
        bbox = {}
        for y in range(self.h):
            for x in range(self.w):
                r = self.rid[y][x]
                if r < 0:
                    continue
                b = bbox.get(r)
                if b is None:
                    bbox[r] = [x, y, x, y]
                else:
                    b[0] = min(b[0], x); b[1] = min(b[1], y)
                    b[2] = max(b[2], x); b[3] = max(b[3], y)
        lx, ly = light
        for y in range(self.h):
            for x in range(self.w):
                r = self.rid[y][x]
                if r < 0:
                    continue
                reg = self.regions[r]
                mat = reg['mat']
                shade = reg['shade']
                idx = 2
                if shade == 'sphere':
                    b = bbox[r]
                    cx = (b[0] + b[2] + 1) / 2.0
                    cy = (b[1] + b[3] + 1) / 2.0
                    rx = max(1.0, (b[2] - b[0] + 1) / 2.0)
                    ry = max(1.0, (b[3] - b[1] + 1) / 2.0)
                    nx = (x + 0.5 - cx) / rx
                    ny = (y + 0.5 - cy) / ry
                    d = nx * lx + ny * ly
                    if d > 0.5:
                        idx = 3
                    elif d < -0.38:
                        idx = 1
                elif shade == 'edge':
                    below = self._inside(x, y + 1, r)
                    right = self._inside(x + 1, y, r)
                    above = self._inside(x, y - 1, r)
                    left = self._inside(x - 1, y, r)
                    if not below or (not right and not self._inside(x + 1, y + 1, r)):
                        idx = 1
                    elif not above and (not left or self._inside(x + 1, y, r)):
                        idx = 3
                elif shade == 'edge_soft':     # shadow only on bottom/right
                    below = self._inside(x, y + 1, r)
                    right = self._inside(x + 1, y, r)
                    if not below or not right:
                        idx = 1
                elif shade == 'dark':
                    idx = 1
                elif shade == 'light':
                    idx = 3
                elif shade == 'flat':
                    idx = 2
                elif shade == 'outline':
                    idx = 0
                px[x, y] = ramp(mat, idx)
                if reg['edge']:
                    # inner line where this region sits over an earlier region
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        xx, yy = x + dx, y + dy
                        if 0 <= xx < self.w and 0 <= yy < self.h:
                            o = self.rid[yy][xx]
                            if o >= 0 and o != r and self.regions[o]['z'] < reg['z'] \
                                    and self.regions[o]['mat'] != mat:
                                px[x, y] = ramp(mat, 0)
                                break
        for (x, y), c in self.detail.items():
            px[x, y] = c
        if outline:
            img = selout(img, self)
        for f in self.post:
            f(img)
        return img


def selout(img, cv=None):
    """Selective outline: transparent pixels touching the sprite take the darkest
    ramp colour of the neighbouring material (coloured outline, not pure black)."""
    w, h = img.size
    src = img.load()
    out = img.copy()
    o = out.load()
    for y in range(h):
        for x in range(w):
            if src[x, y][3] != 0:
                continue
            best = None
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < w and 0 <= yy < h and src[xx, yy][3] != 0:
                    if cv is not None and cv.rid[yy][xx] >= 0:
                        c = ramp(cv.regions[cv.rid[yy][xx]]['mat'], 0)
                    else:
                        r, g, b, a = src[xx, yy]
                        c = (int(r * 0.25), int(g * 0.2), int(b * 0.3), 255)
                    if best is None or sum(c[:3]) < sum(best[:3]):
                        best = c
            if best is not None:
                o[x, y] = best
    return out


def outline_img(img, col=None):
    w, h = img.size
    src = img.load()
    out = img.copy(); o = out.load()
    for y in range(h):
        for x in range(w):
            if src[x, y][3] != 0:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < w and 0 <= yy < h and src[xx, yy][3] != 0:
                    if col is None:
                        r, g, b, a = src[xx, yy]
                        o[x, y] = (int(r * 0.22), int(g * 0.18), int(b * 0.3), 255)
                    else:
                        o[x, y] = hx(col)
                    break
    return out


def shift_rows(img, y0, y1, dy):
    """Move rows [y0,y1) by dy pixels (used for 2-frame breathing idles)."""
    w, h = img.size
    out = img.copy()
    src = img.load(); o = out.load()
    for y in range(y0, y1):
        for x in range(w):
            o[x, y] = (0, 0, 0, 0)
    for y in range(y0, y1):
        ty = y + dy
        if 0 <= ty < h:
            for x in range(w):
                if src[x, y][3]:
                    o[x, ty] = src[x, y]
    # rows between that became empty while the region below exists stay as-is
    return out


def tint(img, col, amount):
    c = hx(col) if isinstance(col, str) else col
    out = img.copy(); o = out.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = o[x, y]
            if a:
                o[x, y] = (int(r + (c[0] - r) * amount), int(g + (c[1] - g) * amount),
                           int(b + (c[2] - b) * amount), a)
    return out


def flip(img):
    return img.transpose(Image.FLIP_LEFT_RIGHT)


def save(img, path, preview_scale=0):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)
    return path


def sheet(images, cols, scale=4, bg=(40, 36, 52, 255), pad=2):
    if not images:
        return None
    cw = max(i.size[0] for i in images) + pad * 2
    ch = max(i.size[1] for i in images) + pad * 2
    rows = (len(images) + cols - 1) // cols
    s = Image.new('RGBA', (cw * cols, ch * rows), bg)
    for k, im in enumerate(images):
        x = (k % cols) * cw + pad
        y = (k // cols) * ch + pad
        s.alpha_composite(im, (x, y))
    return s.resize((s.size[0] * scale, s.size[1] * scale), Image.NEAREST)
