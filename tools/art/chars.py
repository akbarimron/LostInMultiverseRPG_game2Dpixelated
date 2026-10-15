"""32x32 chibi characters (player + stage 1-3 enemies) and 48x48 bosses."""
from pxlib import Canvas, hx, shift_rows, flip, RAMPS, ramp

EYE = '#140c1c'
WHITE = '#ffffff'
BLUSH = '#e8786e'

# ----------------------------------------------------------------------------
# generic humanoid pieces
# ----------------------------------------------------------------------------
HAIR_STYLES = {
    # 19 wide, starts at x=7, y=1
    'neat': [
        "......hhhhhhh......",
        "....hhhhhhhhhhh....",
        "...hhhhhhhhhhhhh...",
        "..hhhhhhhhhhhhhhh..",
        "..hhhhhhhhhhhhhhhh.",
        ".hhhhhhhhhhhhhhhhh.",
        ".hhhhhhhhhhhhhhhhh.",
        ".hhhh.hhhhh..hhhhh.",
        ".hhh...hh.....hhhh.",
        ".hh............hhh.",
        ".hh.............hh.",
        "..h.............h..",
    ],
    'buzz': [
        "...................",
        "...................",
        ".....hhhhhhhhh.....",
        "...hhhhhhhhhhhhh...",
        "..hhhhhhhhhhhhhhh..",
        "..hhhhhhhhhhhhhhh..",
        "..hh...........hh..",
        "..h.............h..",
    ],
    'messy': [
        "....h..hhhh..h.....",
        "...hhhhhhhhhhhhh...",
        "..hhhhhhhhhhhhhhh..",
        ".hhhhhhhhhhhhhhhhh.",
        ".hhhhhhhhhhhhhhhhhh",
        "hhhhhhhhhhhhhhhhhh.",
        ".hhhhhhhhhhhhhhhhhh",
        ".hhh.hhh.hhh.hhhhh.",
        ".hh...h...h....hhh.",
        ".hh.............hh.",
        ".h...............h.",
    ],
    'long': [
        "......hhhhhhh......",
        "....hhhhhhhhhhh....",
        "...hhhhhhhhhhhhh...",
        "..hhhhhhhhhhhhhhh..",
        "..hhhhhhhhhhhhhhh..",
        ".hhhhhhhhhhhhhhhhh.",
        ".hhhhhhhhhhhhhhhhh.",
        ".hhhhhh......hhhhh.",
        ".hhhh.........hhhh.",
        ".hhh...........hhh.",
        ".hhh...........hhh.",
        ".hhh...........hhh.",
        ".hhh...........hhh.",
        ".hhh...........hhh.",
        "..hh...........hh..",
    ],
}


def head(c, skin='skin', cx=16, cy=10.2, rx=8.4, ry=7.6):
    return c.ellipse(cx, cy, rx, ry, skin, shade='sphere')


def hair(c, style, mat='hair', ox=7, oy=1, mirror=False):
    rows = HAIR_STYLES[style]
    if mirror:
        rows = [r[::-1] for r in rows]
    c.stamp(ox, oy, rows, {'h': mat}, shade='flat')
    # simple shading on the hair mass: top-left highlight streak, lower rim shadow
    return rows


def hair_shade(c, rows, mat='hair', ox=7, oy=1):
    hi = ramp(mat, 3); sh = ramp(mat, 1)
    pts = set()
    for j, r in enumerate(rows):
        for i, ch in enumerate(r):
            if ch == 'h':
                pts.add((i, j))
    for (i, j) in pts:
        x, y = ox + i, oy + j
        if (i, j + 1) not in pts:
            c.dot(x, y, sh)
        elif (i, j - 1) not in pts and i < 10:
            c.dot(x, y, hi)
    # glossy streak
    for k in range(3):
        if (5 + k, 2 + (k // 2)) in pts:
            c.dot(ox + 5 + k, oy + 2 + (k // 2), hi)


def eyes(c, f=0, y=11, style='cute', col=EYE, gap=7, x0=12):
    lx = x0 + f
    rx = lx + gap
    if style == 'cute':
        for ex in (lx, rx):
            c.dots([(ex, y), (ex + 1, y), (ex, y + 1), (ex + 1, y + 1)], col)
            c.dot(ex + 1, y, WHITE)
    elif style == 'angry':
        for ex in (lx, rx):
            c.dots([(ex, y + 1), (ex + 1, y + 1)], col)
        c.dots([(lx - 1, y - 1), (lx, y - 1), (lx + 1, y)], col)
        c.dots([(rx + 2, y - 1), (rx + 1, y - 1), (rx, y)], col)
    elif style == 'glow':
        for ex in (lx, rx):
            c.dots([(ex, y), (ex + 1, y)], col)
            c.dot(ex, y + 1, ramp('red', 1))
    elif style == 'dead':
        for ex in (lx, rx):
            c.dots([(ex, y), (ex + 1, y + 1)], col)
            c.dots([(ex + 1, y), (ex, y + 1)], col)
    elif style == 'sly':
        for ex in (lx, rx):
            c.dots([(ex, y + 1), (ex + 1, y + 1)], col)
        c.dots([(lx, y), (rx + 1, y)], col)
    elif style == 'hollow':
        for ex in (lx, rx):
            c.dots([(ex, y), (ex + 1, y), (ex, y + 1), (ex + 1, y + 1), (ex, y + 2), (ex + 1, y + 2)], col)


def body(c, top='white', bottom='grey', shoes='black', skin='skin', sleeve=None,
         wide=0, legs=True, arms=True):
    sleeve = sleeve or top
    c.rrect(11 - wide, 17, 10 + wide * 2, 8, top, shade='edge')
    if legs:
        c.rect(12 - wide // 2, 25, 3, 3, bottom, shade='edge_soft')
        c.rect(17 + wide // 2, 25, 3, 3, bottom, shade='edge_soft')
        c.rrect(11 - wide // 2, 28, 4, 2, shoes, shade='flat')
        c.rrect(17 + wide // 2, 28, 4, 2, shoes, shade='flat')
    if arms:
        c.rect(9 - wide, 18, 2, 5, sleeve, shade='edge_soft')
        c.rect(21 + wide, 18, 2, 5, sleeve, shade='edge_soft')
        c.rect(9 - wide, 23, 2, 2, skin, shade='flat')
        c.rect(21 + wide, 23, 2, 2, skin, shade='flat')


# ----------------------------------------------------------------------------
# PLAYER: Siswa SMA
# ----------------------------------------------------------------------------
def player(pose='idle', f=1):
    c = Canvas(32, 32)
    # backpack behind body
    if pose != 'front':
        c.rrect(6, 17, 5, 8, 'navy', shade='edge')
    body(c, top='white', bottom='grey', shoes='black')
    if pose == 'attack':
        # front arm thrust forward
        c.erase_rect(21, 18, 2, 7)
        c.rect(21, 18, 5, 2, 'white', shade='edge_soft')
        c.rect(26, 18, 2, 2, 'skin', shade='flat')
    if pose == 'defend':
        c.erase_rect(9, 18, 2, 7); c.erase_rect(21, 18, 2, 7)
        c.rect(12, 19, 9, 2, 'white', shade='edge_soft')
        c.rect(14, 21, 7, 2, 'white', shade='edge_soft')
        c.rect(21, 19, 2, 2, 'skin', shade='flat')
        c.rect(21, 21, 2, 2, 'skin', shade='flat')
    head(c)
    rows = hair(c, 'neat', mirror=(f < 0))
    hair_shade(c, rows)
    # face
    if pose == 'hurt':
        eyes(c, f, style='dead')
        c.dots([(16 + f, 15), (17 + f, 15)], ramp('red', 1))
    else:
        eyes(c, f, style='cute')
        c.dot(16 + f, 15, ramp('skin', 0))
        c.dot(17 + f, 15, ramp('skin', 0))
        c.dots([(11 + f, 13), (22 + f, 13)], BLUSH)
    # shirt details: collar, grey tie, OSIS badge, straps
    c.dots([(14, 17), (18, 17)], ramp('white', 1))
    c.dots([(16, 17), (16, 18), (16, 19), (16, 20), (15, 18), (17, 18)], ramp('grey', 2))
    c.dot(16, 21, ramp('grey', 1))
    c.dot(19, 19, ramp('gold', 2))
    c.dot(13, 19, ramp('blue', 2))
    if pose != 'front':
        c.dots([(12, 17), (12, 18), (12, 19), (12, 20)], ramp('navy', 2))
    # belt
    c.dots([(x, 24) for x in range(11, 21)], ramp('black', 2))
    c.dot(16, 24, ramp('metal', 3))
    img = c.render()
    return img


# ----------------------------------------------------------------------------
# STAGE 1 : Dunia Nyata (Kota Kelam)
# ----------------------------------------------------------------------------
def preman(f=-1):
    c = Canvas(32, 32)
    body(c, top='black', bottom='denim', shoes='brown', skin='skin2', sleeve='skin2', wide=1)
    head(c, 'skin2')
    rows = hair(c, 'buzz', mirror=(f < 0))
    hair_shade(c, rows)
    eyes(c, f, style='angry')
    # stubble + scowl + scar
    c.dots([(14 + f, 15), (15 + f, 15), (16 + f, 15), (17 + f, 15)], ramp('skin2', 0))
    c.dots([(13 + f, 16), (15 + f, 16), (17 + f, 16), (19 + f, 16)], ramp('skin2', 1))
    c.dots([(20 + f, 8), (21 + f, 9), (21 + f, 10)], ramp('red', 1))
    # gold chain
    c.dots([(13, 18), (14, 19), (15, 20), (16, 20), (17, 20), (18, 19), (19, 18)], ramp('gold', 3))
    # arm tattoo
    c.dots([(9 - 1, 19), (9 - 1, 21), (22 + 1, 20)], ramp('teal', 1))
    return c.render()


def copet(f=-1):
    c = Canvas(32, 32)
    body(c, top='olive', bottom='grey', shoes='black', skin='skin')
    # hoodie pocket
    c.dots([(x, 22) for x in range(13, 19)], ramp('olive', 1))
    head(c, 'skin')
    # beanie
    c.stamp(7, 1, [
        "...................",
        "......bbbbbbb......",
        "....bbbbbbbbbbb....",
        "...bbbbbbbbbbbbb...",
        "..bbbbbbbbbbbbbbb..",
        "..bbbbbbbbbbbbbbb..",
        ".rrrrrrrrrrrrrrrrr.",
        ".rrrrrrrrrrrrrrrrr.",
    ], {'b': 'red', 'r': 'black'}, shade='edge')
    c.dot(16, 1, ramp('red', 3)); c.dot(16, 0, ramp('red', 2))
    eyes(c, f, style='sly')
    # sly grin
    c.dots([(14 + f, 15), (15 + f, 15), (16 + f, 15), (17 + f, 14)], ramp('skin', 0))
    # holding stolen wallet
    c.rrect(5, 22, 4, 3, 'brown', shade='edge')
    c.dot(6, 23, ramp('gold', 3))
    return c.render()


def begal(f=-1):
    c = Canvas(32, 32)
    # golok (machete) held up in back hand
    c.poly([(25, 10), (28, 7), (29, 8), (26, 13), (25, 13)], 'metal', shade='edge')
    c.rect(24, 13, 2, 4, 'wood', shade='flat')
    body(c, top='black', bottom='denim', shoes='black', skin='skin2', sleeve='black')
    c.dots([(x, 20) for x in range(11, 21)], ramp('red', 2))     # jacket stripe
    # full face helmet
    c.ellipse(16, 10, 9.2, 8.4, 'red', shade='sphere')
    c.rrect(9 + (0 if f < 0 else 2), 8, 13, 6, 'black', shade='flat')
    # visor reflection
    c.dots([(11 + (0 if f < 0 else 2), 9), (12 + (0 if f < 0 else 2), 9), (13 + (0 if f < 0 else 2), 9)], ramp('glass', 2))
    c.dots([(12 + (0 if f < 0 else 2), 10)], ramp('glass', 1))
    # glowing eyes behind the visor
    c.dots([(14 + f, 11), (19 + f, 11)], '#ff4a3a')
    c.dots([(x, 4) for x in range(13, 20)], ramp('white', 2))   # helmet stripe
    return c.render()


def perampok(f=-1):
    c = Canvas(32, 32)
    # sack over shoulder
    c.ellipse(24.5, 16.5, 5, 5.5, 'khaki', shade='sphere')
    c.dots([(23, 12), (24, 11), (25, 12)], ramp('khaki', 0))
    c.dot(24, 16, ramp('khaki', 0)); c.dot(25, 17, ramp('khaki', 0)); c.dot(23, 17, ramp('khaki', 0))
    body(c, top='white', bottom='black', shoes='black', skin='skin', sleeve='white')
    # stripes
    for y in (18, 20, 22):
        c.dots([(x, y) for x in range(11, 21)], ramp('black', 2))
    c.dots([(9, 19), (10, 19), (9, 21), (10, 21), (21, 19), (22, 19), (21, 21), (22, 21)], ramp('black', 2))
    # balaclava
    head(c, 'black')
    c.rrect(10 + (1 if f > 0 else 0), 9, 12, 4, 'skin', shade='flat')
    eyes(c, f, y=10, style='angry', col='#ffffff')
    c.dots([(12 + f, 11), (19 + f, 11)], EYE)
    c.rrect(14 + f, 14, 4, 2, 'skin', shade='flat')
    c.dots([(15 + f, 15), (16 + f, 15)], ramp('red', 1))
    # crowbar
    c.line([(7, 12), (7, 25)], 'red', width=1)
    c.dots([(6, 12), (8, 11)], ramp('red', 2))
    return c.render()


def anjing(f=-1):
    c = Canvas(32, 32)
    # body
    c.ellipse(18, 20, 9, 5.5, 'brown', shade='sphere')
    # legs
    for x in (11, 14, 20, 23):
        c.rect(x, 23, 2, 6, 'brown', shade='edge_soft')
        c.rect(x, 28, 2, 1, 'brown', shade='dark')
    # tail
    c.line([(26, 17), (28, 13), (29, 12)], 'brown', width=1, shade='edge')
    # head
    c.ellipse(9, 15, 6, 5, 'brown', shade='sphere')
    c.rrect(2, 15, 6, 4, 'brown', shade='edge')
    # ears
    c.poly([(7, 10), (9, 6), (11, 10)], 'brown', shade='dark')
    c.poly([(11, 11), (13, 7), (14, 11)], 'brown', shade='edge')
    c.dot(2, 15, ramp('black', 0))
    c.dots([(6, 13), (10, 13)], '#ff3a2a')
    c.dots([(3, 18), (4, 18), (5, 18)], ramp('black', 1))
    c.dots([(4, 19), (6, 19)], ramp('white', 3))       # fangs
    c.dots([(5, 20), (5, 21)], ramp('glass', 2))        # drool
    # mange spots
    c.dots([(17, 18), (21, 19), (19, 21), (15, 22)], ramp('brown', 1))
    c.dots([(18, 17), (22, 18)], ramp('flesh', 2))
    img = c.render()
    return img if f < 0 else flip(img)


def jagoan(f=-1):
    """Elite stage 1: big village tough with bamboo stick"""
    c = Canvas(32, 32)
    c.rect(26, 5, 2, 24, 'khaki', shade='edge_soft')
    for y in (9, 15, 21):
        c.dots([(26, y), (27, y)], ramp('khaki', 0))
    c.rrect(8, 16, 16, 10, 'skin2', shade='edge')
    c.rrect(8, 22, 16, 5, 'green', shade='edge')       # sarong
    c.dots([(x, 24) for x in range(9, 23, 2)], ramp('green', 3))
    c.rect(10, 27, 4, 2, 'skin2', shade='flat'); c.rect(18, 27, 4, 2, 'skin2', shade='flat')
    c.rrect(9, 29, 5, 2, 'black'); c.rrect(18, 29, 5, 2, 'black')
    c.rect(5, 17, 3, 7, 'skin2', shade='edge_soft'); c.rect(24, 17, 3, 7, 'skin2', shade='edge_soft')
    head(c, 'skin2', cy=10, rx=8, ry=7.2)
    c.stamp(7, 2, [
        "...rrrrrrrrrrrrr...",
        "..rrrrrrrrrrrrrrr..",
        "..rrrrrrrrrrrrrrr.r",
        ".................rr",
    ], {'r': 'red'}, shade='edge')
    eyes(c, f, style='angry')
    c.dots([(13 + f, 14), (14 + f, 14), (15 + f, 14), (16 + f, 14), (17 + f, 14), (18 + f, 14)], ramp('hair', 1))  # mustache
    c.dots([(12 + f, 15), (19 + f, 15)], ramp('hair', 1))
    c.dots([(15, 19), (16, 19), (14, 20), (17, 20)], ramp('skin2', 1))    # chest
    return c.render()


# ----------------------------------------------------------------------------
# STAGE 2 : Dimensi Kegelapan
# ----------------------------------------------------------------------------
def imp(f=-1):
    c = Canvas(32, 32)
    # wings
    c.poly([(9, 15), (2, 9), (3, 15), (1, 18), (6, 19), (9, 20)], 'purple', shade='edge')
    c.poly([(23, 15), (30, 9), (29, 15), (31, 18), (26, 19), (23, 20)], 'purple', shade='edge')
    # tail
    c.line([(20, 25), (24, 27), (27, 25)], 'imp', width=1)
    c.poly([(27, 23), (29, 25), (27, 26)], 'imp', shade='flat')
    c.ellipse(16, 21.5, 5, 5, 'imp', shade='sphere')
    c.rect(12, 25, 3, 4, 'imp', shade='edge_soft'); c.rect(17, 25, 3, 4, 'imp', shade='edge_soft')
    c.dots([(11, 29), (12, 29), (13, 29), (18, 29), (19, 29), (20, 29)], ramp('black', 1))
    c.rect(10, 19, 2, 4, 'imp', shade='edge_soft'); c.rect(20, 19, 2, 4, 'imp', shade='edge_soft')
    c.ellipse(16, 11, 7.5, 6.8, 'imp', shade='sphere')
    # horns
    c.poly([(10, 7), (8, 1), (12, 5)], 'bone', shade='edge')
    c.poly([(22, 7), (24, 1), (20, 5)], 'bone', shade='edge')
    eyes(c, f, y=10, style='glow', col='#ffe23a')
    # grin with fangs
    c.dots([(12 + f, 14), (13 + f, 15), (14 + f, 15), (15 + f, 15), (16 + f, 15), (17 + f, 15), (18 + f, 15), (19 + f, 14)], ramp('black', 0))
    c.dots([(14 + f, 14), (17 + f, 14)], WHITE)
    c.dots([(16, 20), (15, 21), (17, 21)], ramp('imp', 1))
    return c.render()


def pocong(f=-1):
    c = Canvas(32, 32)
    # shroud body (capsule)
    c.ellipse(16, 18, 7.5, 12.5, 'cloth', shade='sphere')
    c.erase_rect(0, 30, 32, 2)
    # top knot "ears"
    c.poly([(14, 6), (12, 1), (15, 4), (16, 5), (17, 4), (20, 1), (18, 6)], 'cloth', shade='edge')
    # ties
    for y in (8, 19, 27):
        c.dots([(x, y) for x in range(10, 23)], ramp('cloth', 1))
    # face window
    c.ellipse(16 + f, 12.5, 4.5, 4, 'zomb', shade='flat')
    c.dots([(14 + f, 11), (15 + f, 11), (14 + f, 12), (15 + f, 12), (18 + f, 11), (19 + f, 11), (18 + f, 12), (19 + f, 12)], '#0a0610')
    c.dots([(15 + f, 11), (18 + f, 11)], '#ff3030')
    c.dots([(16 + f, 15), (17 + f, 15)], ramp('zomb', 0))
    # dirt stains
    c.dots([(11, 22), (12, 23), (20, 24), (21, 25), (13, 28)], ramp('khaki', 1))
    return c.render()


def bayangan(f=-1):
    c = Canvas(32, 32)
    c.ellipse(16, 18, 9, 11, 'shadow', shade='sphere')
    c.ellipse(16, 10, 7, 7, 'shadow', shade='sphere')
    # arms stretching
    c.poly([(8, 15), (3, 22), (4, 23), (9, 19)], 'shadow', shade='flat')
    c.poly([(24, 15), (29, 22), (28, 23), (23, 19)], 'shadow', shade='flat')
    # wispy tail with holes (dither)
    for x in range(7, 26):
        for y in range(25, 31):
            if (x + y) % 2 == 0 and y > 26:
                c.erase_px([(x, y)])
    c.erase_px([(7, 25), (8, 26), (24, 25), (25, 26), (10, 30), (22, 30)])
    eyes(c, f, y=9, style='glow', col='#d8b8ff', x0=12)
    c.dots([(13 + f, 10), (20 + f, 10)], '#7a4ad0')
    # mouth slit
    c.dots([(14 + f, 14), (15 + f, 15), (16 + f, 15), (17 + f, 15), (18 + f, 14)], '#7a4ad0')
    img = c.render()
    # purple aura outline
    from pxlib import outline_img
    return outline_img(img, '#3a1858')


def iblis(f=-1):
    c = Canvas(32, 32)
    # trident
    c.rect(26, 4, 1, 26, 'metal', shade='flat')
    c.stamp(24, 1, ["x.x.x", "x.x.x", "xxxxx"], {'x': 'metal'})
    c.rrect(9, 16, 14, 10, 'demon', shade='edge')
    c.rect(11, 23, 10, 3, 'black', shade='flat')      # loincloth belt
    c.poly([(13, 26), (19, 26), (16, 29)], 'black', shade='flat')
    c.rect(11, 26, 3, 3, 'demon', shade='edge_soft'); c.rect(18, 26, 3, 3, 'demon', shade='edge_soft')
    c.rect(10, 29, 4, 1, 'black'); c.rect(18, 29, 4, 1, 'black')
    c.rect(6, 17, 3, 7, 'demon', shade='edge_soft'); c.rect(23, 17, 3, 7, 'demon', shade='edge_soft')
    head(c, 'demon', cy=10, rx=7.6, ry=7)
    c.poly([(9, 7), (4, 4), (3, 0), (7, 2), (11, 5)], 'bone', shade='edge')
    c.poly([(23, 7), (28, 4), (29, 0), (25, 2), (21, 5)], 'bone', shade='edge')
    eyes(c, f, y=10, style='angry', col='#ffe23a')
    c.dots([(12 + f, 11), (19 + f, 11)], '#ffe23a')
    c.dots([(13 + f, 14), (14 + f, 14), (15 + f, 14), (16 + f, 14), (17 + f, 14), (18 + f, 14)], ramp('black', 0))
    c.dots([(13 + f, 15), (18 + f, 15)], WHITE)
    c.dots([(14, 19), (17, 19), (15, 21), (16, 21)], ramp('demon', 1))
    return c.render()


def tuyul(f=-1):
    c = Canvas(32, 32)
    c.ellipse(16, 23, 5.5, 4.5, 'zomb', shade='sphere')
    c.rect(12, 26, 3, 3, 'zomb', shade='edge_soft'); c.rect(17, 26, 3, 3, 'zomb', shade='edge_soft')
    c.rect(12, 26, 8, 2, 'cloth', shade='edge')      # diaper/loincloth
    c.rect(9, 21, 2, 4, 'zomb', shade='edge_soft'); c.rect(21, 21, 2, 4, 'zomb', shade='edge_soft')
    # big bald head + ears
    c.poly([(6, 10), (2, 7), (5, 13)], 'zomb', shade='edge')
    c.poly([(26, 10), (30, 7), (27, 13)], 'zomb', shade='edge')
    c.ellipse(16, 12, 9, 8.5, 'zomb', shade='sphere')
    eyes(c, f, y=12, style='glow', col='#ff3030')
    c.dots([(14 + f, 16), (15 + f, 17), (16 + f, 17), (17 + f, 17), (18 + f, 16)], ramp('zomb', 0))
    c.dot(16 + f, 16, WHITE)
    # stolen coin
    c.ellipse(24, 24, 2.6, 2.6, 'gold', shade='sphere')
    return c.render()


def hellhound(f=-1):
    c = Canvas(32, 32)
    # flame mane
    c.poly([(4, 12), (6, 4), (8, 8), (10, 2), (12, 7), (15, 3), (16, 10), (18, 14), (6, 18)], 'fire', shade='edge')
    c.ellipse(19, 20, 9.5, 5.5, 'black', shade='sphere')
    for x in (12, 15, 21, 24):
        c.rect(x, 23, 2, 6, 'black', shade='edge_soft')
    c.line([(27, 18), (30, 13)], 'fire', width=2)
    c.ellipse(9, 15, 6, 5, 'black', shade='sphere')
    c.rrect(1, 15, 7, 4, 'black', shade='edge')
    c.dots([(5, 13), (8, 13), (11, 13)], '#ffcc22')      # three eyes
    c.dots([(5, 14), (8, 14), (11, 14)], '#ff4a10')
    c.dots([(2, 18), (3, 18), (4, 18), (5, 18), (6, 18)], ramp('lava', 2))
    c.dots([(3, 19), (5, 19)], WHITE)
    c.dots([(16, 22), (19, 23), (22, 21)], ramp('lava', 1))   # cracks
    img = c.render()
    return img if f < 0 else flip(img)


# ----------------------------------------------------------------------------
# STAGE 3 : Dimensi Tumor
# ----------------------------------------------------------------------------
def tumor_blob(f=-1):
    c = Canvas(32, 32)
    c.ellipse(16, 20, 12, 9.5, 'flesh', shade='sphere')
    c.ellipse(9, 12, 5, 5, 'flesh', shade='sphere')
    c.ellipse(21, 10, 6, 6, 'flesh2', shade='sphere')
    c.ellipse(26, 18, 3.5, 3.5, 'flesh2', shade='sphere')
    c.ellipse(5, 22, 3, 3, 'pus', shade='sphere')
    # eyes of different sizes
    c.ellipse(21, 10, 2.6, 2.6, 'eye', shade='flat')
    c.dots([(21, 10), (22, 10), (21, 11)], EYE)
    c.dots([(9, 12), (10, 12)], EYE); c.dot(10, 11, WHITE)
    c.dots([(14, 19), (17, 18)], EYE)
    # mouth
    c.dots([(11, 23), (12, 24), (13, 24), (14, 25), (15, 25), (16, 25), (17, 24), (18, 24), (19, 23)], ramp('vein', 0))
    c.dots([(13, 25), (16, 26), (18, 25)], ramp('bone', 3))
    c.dots([(24, 21), (25, 22), (8, 18), (7, 17)], ramp('vein', 2))
    return c.render()


def eye_cluster(f=-1):
    c = Canvas(32, 32)
    c.poly([(13, 30), (19, 30), (18, 18), (14, 18)], 'flesh2', shade='edge')
    c.dots([(15, 21), (16, 24), (17, 27)], ramp('vein', 2))
    for (ex, ey, r) in ((16, 11, 6.5), (7, 9, 4), (25, 8, 4.5), (9, 19, 3.5), (24, 18, 3.6), (16, 3, 2.8)):
        c.ellipse(ex, ey, r, r, 'eye', shade='sphere')
        c.ellipse(ex + f * 0.8, ey + 0.4, max(1.2, r * 0.45), max(1.2, r * 0.45), 'red', shade='flat')
        c.dot(int(ex + f * 0.8), int(ey), EYE)
    c.dots([(13, 7), (14, 6), (20, 13), (19, 15)], ramp('vein', 2))
    return c.render()


def cacing(f=-1):
    c = Canvas(32, 32)
    seg = [(25, 27, 3.3), (21, 28, 3.6), (16, 28, 3.8), (11, 26, 3.9), (8, 22, 4), (9, 17, 4.1), (13, 13, 4.3)]
    for (x, y, r) in seg:
        c.ellipse(x, y, r, r * 0.9, 'pink', shade='sphere')
    c.ellipse(17, 9, 6, 6, 'pink', shade='sphere')
    # round toothy mouth
    c.ellipse(18, 9, 3.6, 3.6, 'vein', shade='flat')
    c.ellipse(18, 9, 1.8, 1.8, 'black', shade='flat')
    c.dots([(18, 6), (15, 9), (21, 9), (18, 12), (16, 7), (20, 7), (16, 11), (20, 11)], ramp('bone', 3))
    for (x, y, r) in seg:
        c.dot(int(x), int(y - r * 0.6), ramp('pink', 1))
    return c.render()


def daging_jalan(f=-1):
    c = Canvas(32, 32)
    c.rect(11, 24, 4, 6, 'flesh2', shade='edge_soft')
    c.rect(18, 24, 3, 6, 'flesh2', shade='edge_soft')
    c.ellipse(16, 18, 8, 8, 'flesh', shade='sphere')
    # big lump arm
    c.ellipse(6, 19, 4.5, 6, 'flesh2', shade='sphere')
    c.rect(24, 16, 2, 9, 'flesh', shade='edge_soft')
    c.ellipse(15, 9, 6.5, 6, 'flesh', shade='sphere')
    c.ellipse(14 + f, 9, 3.4, 3.4, 'eye', shade='flat')
    c.ellipse(14 + f * 1.5, 9.5, 1.6, 1.6, 'pus', shade='flat')
    c.dot(int(14 + f * 1.5), 9, EYE)
    c.dots([(12, 15), (13, 16), (14, 16), (15, 16), (16, 16), (17, 15)], ramp('vein', 0))
    c.dots([(14, 17), (16, 17)], ramp('bone', 3))
    c.dots([(18, 19), (19, 21), (20, 20), (6, 16), (7, 21)], ramp('vein', 2))
    c.ellipse(21, 12, 2, 2, 'pus', shade='sphere')
    return c.render()


def spora(f=-1):
    c = Canvas(32, 32)
    c.ellipse(16, 22, 9, 7.5, 'khaki', shade='sphere')
    c.ellipse(9, 12, 6, 4, 'slime', shade='sphere')
    c.rect(8, 14, 2, 6, 'khaki', shade='edge_soft')
    c.ellipse(21, 9, 7, 4.5, 'purple', shade='sphere')
    c.rect(20, 12, 2, 6, 'khaki', shade='edge_soft')
    c.ellipse(16, 4, 3.5, 2.5, 'slime', shade='sphere')
    c.rect(15, 6, 2, 6, 'khaki', shade='edge_soft')
    c.dots([(18, 7), (22, 8), (25, 10), (7, 11), (10, 12)], ramp('pus', 3))
    # gaping sac mouth
    c.ellipse(16, 23, 3.5, 2.5, 'vein', shade='flat')
    c.dots([(14, 22), (18, 22)], ramp('bone', 3))
    c.dots([(9, 20), (22, 19), (12, 26), (21, 26)], ramp('khaki', 1))
    # floating spores
    c.dots([(4, 4), (27, 3), (29, 17), (3, 20)], ramp('slime', 3))
    return c.render()


def ahli_bedah(f=-1):
    """Elite stage 3: surgeon horror"""
    c = Canvas(32, 32)
    # gown
    c.poly([(10, 15), (22, 15), (24, 29), (8, 29)], 'teal', shade='edge')
    c.dots([(12, 22), (13, 23), (19, 20), (20, 25), (11, 27), (15, 26)], ramp('red', 2))
    c.rect(11, 29, 3, 2, 'black'); c.rect(18, 29, 3, 2, 'black')
    # scalpel arms
    c.line([(9, 17), (4, 22), (3, 26)], 'pale', width=2)
    c.line([(23, 17), (28, 22), (29, 26)], 'pale', width=2)
    c.poly([(2, 26), (4, 26), (3, 31)], 'metal', shade='edge')
    c.poly([(28, 26), (30, 26), (29, 31)], 'metal', shade='edge')
    head(c, 'pale', cy=9, rx=6.8, ry=6.8)
    c.rrect(10, 2, 13, 4, 'teal', shade='edge')        # cap
    c.rrect(10, 11, 13, 5, 'glass', shade='flat')       # mask
    c.dots([(11, 12), (12, 12)], ramp('glass', 3))
    c.dots([(13 + f, 8), (14 + f, 8), (18 + f, 8), (19 + f, 8)], EYE)
    c.dots([(14 + f, 8), (18 + f, 8)], '#ff3030')
    c.dots([(15, 13), (16, 14), (17, 13)], ramp('red', 2))
    return c.render()


# ----------------------------------------------------------------------------
# BOSSES 48x48
# ----------------------------------------------------------------------------
def boss_jagal(f=-1):
    c = Canvas(48, 48)
    # cleaver
    c.rect(40, 18, 2, 10, 'wood', shade='flat')
    c.rrect(36, 6, 9, 13, 'metal', shade='edge')
    c.dots([(37, 8), (38, 8), (37, 9)], ramp('red', 2))
    c.dot(40, 8, ramp('black', 1))
    # body
    c.rrect(11, 22, 26, 17, 'white', shade='edge')       # undershirt
    c.rrect(14, 24, 20, 16, 'khaki', shade='edge')        # apron
    c.dots([(18, 30), (19, 31), (25, 28), (26, 29), (22, 35), (29, 33), (16, 36)], ramp('red', 2))
    c.dots([(19, 30), (26, 28), (23, 35)], ramp('red', 1))
    c.rect(15, 40, 6, 4, 'grey', shade='edge_soft'); c.rect(27, 40, 6, 4, 'grey', shade='edge_soft')
    c.rrect(13, 44, 8, 3, 'black'); c.rrect(27, 44, 8, 3, 'black')
    c.ellipse(8, 28, 4.2, 7.5, 'skin2', shade='sphere')
    c.ellipse(39, 24, 3.8, 6.5, 'skin2', shade='sphere')
    c.ellipse(8, 36, 3.6, 3, 'skin2', shade='sphere')
    c.dots([(7, 25), (8, 27), (6, 29)], ramp('teal', 1))
    # head
    c.ellipse(24, 13, 11, 10, 'skin2', shade='sphere')
    c.dots([(17, 7), (18, 7), (19, 8), (28, 8), (29, 7), (30, 7)], ramp('skin2', 0))   # brows
    c.dots([(19, 5), (20, 5), (21, 4)], ramp('skin2', 3))                          # shine
    c.rrect(14, 10, 20, 4, 'black', shade='flat')        # sunglasses
    c.dots([(16, 11), (17, 11), (27, 11), (28, 11)], ramp('glass', 2))
    c.dots([(18, 18), (19, 19), (20, 19), (21, 19), (22, 19), (23, 19), (24, 19), (25, 19), (26, 19), (27, 19), (28, 18)], ramp('skin2', 0))
    c.dots([(20, 20), (23, 20), (26, 20)], ramp('gold', 3))   # gold teeth
    c.dots([(30, 5), (31, 6), (32, 7), (33, 8)], ramp('red', 1))   # scar
    c.dots([(x, 21) for x in range(17, 31, 2)], ramp('skin2', 1))
    return c.render()


def boss_raja(f=-1):
    c = Canvas(48, 48)
    # flames behind
    c.poly([(4, 46), (3, 30), (7, 34), (8, 22), (12, 28), (14, 18), (18, 26), (24, 14), (30, 26), (34, 18),
            (36, 28), (40, 22), (41, 34), (45, 30), (44, 46)], 'fire', shade='edge')
    # cloak
    c.poly([(10, 46), (14, 22), (34, 22), (38, 46)], 'purple', shade='edge')
    c.poly([(19, 46), (21, 26), (27, 26), (29, 46)], 'black', shade='flat')
    c.dots([(24, 30), (24, 34), (24, 38)], ramp('gold', 3))
    # shoulders
    c.ellipse(13, 24, 5, 4, 'bone', shade='sphere'); c.ellipse(35, 24, 5, 4, 'bone', shade='sphere')
    c.dots([(11, 22), (37, 22)], ramp('bone', 0))
    # head
    c.ellipse(24, 16, 8, 8, 'demon', shade='sphere')
    # crown of horns
    for (x, h) in ((14, 10), (18, 14), (24, 16), (30, 14), (34, 10)):
        c.poly([(x - 2, 11), (x, 11 - h // 2 - 1), (x + 2, 11)], 'bone', shade='edge')
    c.rrect(15, 9, 18, 3, 'gold', shade='edge')
    c.dots([(19, 10), (24, 10), (29, 10)], ramp('red', 3))
    eyes(c, 0, y=15, style='glow', col='#ffffff', x0=20, gap=6)
    c.dots([(20, 16), (21, 16), (26, 16), (27, 16)], '#ff2a2a')
    c.dots([(20, 20), (21, 21), (22, 21), (23, 21), (24, 21), (25, 21), (26, 21), (27, 20)], ramp('black', 0))
    c.dots([(21, 20), (23, 20), (25, 20)], WHITE)
    # clawed hands
    c.ellipse(9, 33, 3, 3, 'demon', shade='sphere'); c.ellipse(39, 33, 3, 3, 'demon', shade='sphere')
    c.ellipse(39, 28, 3, 3, 'purple', shade='sphere')
    c.ellipse(39, 28, 1.5, 1.5, 'pink', shade='flat')
    return c.render()


def boss_induk(f=-1):
    c = Canvas(48, 48)
    # tentacles
    c.line([(6, 44), (3, 36), (6, 28), (4, 22)], 'flesh2', width=3)
    c.line([(42, 44), (45, 36), (42, 28), (44, 20)], 'flesh2', width=3)
    c.line([(14, 46), (10, 40)], 'flesh2', width=3)
    c.line([(34, 46), (38, 40)], 'flesh2', width=3)
    c.ellipse(24, 30, 18, 15, 'flesh', shade='sphere')
    c.ellipse(13, 17, 7, 7, 'flesh2', shade='sphere')
    c.ellipse(34, 14, 8, 8, 'flesh', shade='sphere')
    c.ellipse(24, 10, 5, 5, 'flesh2', shade='sphere')
    # face in the mass
    c.ellipse(24, 30, 9, 8, 'pale', shade='sphere')
    c.dots([(20, 28), (21, 28), (27, 28), (28, 28)], EYE)
    c.dots([(20, 29), (28, 29)], ramp('red', 1))
    c.dots([(x, 34) for x in range(20, 29)], ramp('vein', 0))
    c.dots([(21, 35), (23, 35), (25, 35), (27, 35)], ramp('bone', 3))
    c.dots([(19, 30), (19, 31), (29, 30), (29, 32)], '#7a2030')   # tears of blood
    # many eyes
    for (x, y, r) in ((34, 14, 3.4), (13, 17, 2.6), (24, 10, 2.0), (9, 30, 2.2), (39, 30, 2.6), (31, 41, 2.0), (16, 41, 1.8)):
        c.ellipse(x, y, r, r, 'eye', shade='flat')
        c.dot(int(x), int(y), EYE)
        c.dot(int(x) + 1, int(y), EYE)
    # veins
    c.dots([(10, 24), (11, 25), (12, 26), (36, 24), (35, 25), (34, 26), (24, 20), (24, 21), (23, 22)], ramp('vein', 2))
    c.ellipse(15, 36, 2.5, 2.5, 'pus', shade='sphere')
    c.ellipse(36, 37, 2, 2, 'pus', shade='sphere')
    return c.render()


def mimic(f=-1):
    c = Canvas(32, 32)
    c.rrect(5, 15, 22, 13, 'wood', shade='edge')
    c.poly([(5, 15), (8, 5), (24, 5), (27, 15)], 'wood', shade='edge')   # lid opened
    c.rect(5, 15, 22, 2, 'gold', shade='flat')
    c.rect(5, 26, 22, 2, 'gold', shade='flat')
    c.rect(14, 18, 4, 4, 'gold', shade='edge')
    # mouth with teeth & tongue
    c.rect(7, 13, 18, 3, 'vein', shade='flat')
    c.dots([(8, 13), (10, 13), (12, 13), (14, 13), (16, 13), (18, 13), (20, 13), (22, 13), (24, 13)], WHITE)
    c.dots([(9, 15), (11, 15), (13, 15), (15, 15), (17, 15), (19, 15), (21, 15), (23, 15)], WHITE)
    c.poly([(14, 15), (18, 15), (19, 20), (16, 22), (13, 20)], 'pink', shade='edge')
    c.dots([(11, 9), (20, 9)], '#ff3030')
    return c.render()


PLAYER = {
    'idle': lambda: player('idle'),
    'attack': lambda: player('attack'),
    'hurt': lambda: player('hurt'),
    'defend': lambda: player('defend'),
    'front': lambda: player('front', f=0),
}

ENEMIES = {
    # stage 1
    'preman': preman, 'copet': copet, 'begal': begal, 'perampok': perampok, 'anjing': anjing,
    'jagoan': jagoan, 'boss_jagal': boss_jagal,
    # stage 2
    'imp': imp, 'pocong': pocong, 'bayangan': bayangan, 'iblis': iblis, 'tuyul': tuyul,
    'hellhound': hellhound, 'boss_raja': boss_raja,
    # stage 3
    'tumor': tumor_blob, 'mata': eye_cluster, 'cacing': cacing, 'daging': daging_jalan, 'spora': spora,
    'bedah': ahli_bedah, 'boss_induk': boss_induk,
    'mimic': mimic,
}
