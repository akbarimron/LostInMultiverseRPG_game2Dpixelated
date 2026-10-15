"""Status icons, stat icons, dice, board tiles/props/backgrounds, UI 9-slices, VFX."""
import random, math
from PIL import Image, ImageDraw
from pxlib import Canvas, ramp, hx, outline_img, RAMPS

W = '#ffffff'
INK = '#140c1c'


# =============================================================== status icons 12x12
def _st(bg):
    """Rounded badge background in given ramp, returns canvas"""
    c = Canvas(12, 12)
    c.rrect(0, 0, 12, 12, bg, shade='flat')
    for x in range(1, 11):
        c.dot(x, 0, ramp(bg, 3)) if False else None
    return c


def st_bleed():
    c = Canvas(12, 12)
    c.poly([(6, 0), (10, 6), (9, 10), (6, 11), (3, 10), (2, 6)], 'red', shade='sphere')
    c.dots([(4, 6), (4, 7)], ramp('red', 3))
    return c.render()


def st_infect():
    c = Canvas(12, 12)
    c.ellipse(6, 6, 4, 4, 'slime', shade='sphere')
    for (x, y) in ((6, 0), (6, 11), (0, 6), (11, 6), (2, 2), (9, 2), (2, 9), (9, 9)):
        c.dot(x, y, ramp('slime', 2))
    c.dots([(5, 5), (7, 7)], ramp('pus', 3))
    return c.render()


def st_fracture_arm():
    c = Canvas(12, 12)
    c.line([(1, 10), (4, 7)], 'bone', width=2)
    c.line([(7, 4), (10, 1)], 'bone', width=2)
    c.dots([(5, 5), (6, 6), (4, 4), (7, 7)], ramp('red', 2))
    c.dots([(0, 11), (11, 0)], ramp('bone', 3))
    return c.render()


def st_fracture_leg():
    c = Canvas(12, 12)
    c.rect(4, 0, 3, 5, 'bone', shade='edge')
    c.rect(4, 7, 3, 5, 'bone', shade='edge')
    c.dots([(3, 5), (5, 6), (7, 5), (8, 6)], ramp('red', 2))
    return c.render()


def st_stun():
    c = Canvas(12, 12)
    for (x, y) in ((2, 3), (8, 2), (5, 8)):
        c.dots([(x, y - 1), (x - 1, y), (x, y), (x + 1, y), (x, y + 1)], ramp('yellow', 3))
    return c.render()


def st_poison():
    c = Canvas(12, 12)
    c.ellipse(6, 5, 4.5, 4, 'green', shade='sphere')
    c.rect(4, 8, 5, 3, 'green', shade='edge')
    c.dots([(4, 5), (8, 5), (5, 10), (7, 10)], INK)
    return c.render()


def st_toxic():
    c = Canvas(12, 12)
    c.ellipse(6, 5, 4.5, 4, 'purple', shade='sphere')
    c.rect(4, 8, 5, 3, 'purple', shade='edge')
    c.dots([(4, 5), (8, 5), (5, 10), (7, 10)], '#a8e272')
    return c.render()


def st_parasite():
    c = Canvas(12, 12)
    c.line([(1, 9), (3, 6), (6, 8), (8, 4), (10, 3)], 'pink', width=2)
    c.dot(10, 2, INK)
    return c.render()


def st_blind():
    c = Canvas(12, 12)
    c.ellipse(6, 6, 5.5, 3.5, 'eye', shade='flat')
    c.ellipse(6, 6, 2, 2, 'black', shade='flat')
    c.line([(1, 10), (10, 1)], 'red', width=1)
    return c.render()


def st_trauma():
    c = Canvas(12, 12)
    c.ellipse(4, 4.5, 3, 3, 'red', shade='sphere')
    c.ellipse(8, 4.5, 3, 3, 'red', shade='sphere')
    c.poly([(1, 5), (11, 5), (6, 11)], 'red', shade='edge')
    c.dots([(6, 2), (5, 4), (6, 6), (5, 8), (6, 9)], INK)
    return c.render()


def st_burn():
    c = Canvas(12, 12)
    c.poly([(6, 0), (9, 4), (10, 8), (8, 11), (4, 11), (2, 8), (3, 5), (5, 6)], 'fire', shade='edge')
    c.poly([(6, 5), (8, 8), (7, 10), (5, 10), (4, 8)], 'yellow', shade='flat')
    return c.render()


def st_defdown():
    c = Canvas(12, 12)
    c.poly([(1, 1), (10, 1), (10, 6), (6, 11), (1, 6)], 'metal', shade='edge')
    c.dots([(6, 2), (5, 4), (6, 5), (5, 7), (6, 8)], INK)
    return c.render()


def st_silence():
    c = Canvas(12, 12)
    c.ellipse(6, 6, 5, 5, 'pale', shade='sphere')
    c.rect(3, 6, 6, 2, 'red', shade='flat')
    c.dots([(4, 4), (7, 4)], INK)
    return c.render()


def st_fear():
    c = Canvas(12, 12)
    c.ellipse(6, 5, 5, 5, 'pale', shade='sphere')
    c.rect(2, 8, 8, 3, 'pale', shade='edge')
    c.erase_px([(3, 11), (6, 11), (9, 11)])
    c.dots([(3, 4), (4, 4), (3, 5), (4, 5), (7, 4), (8, 4), (7, 5), (8, 5)], INK)
    c.dots([(5, 8), (6, 8), (5, 9), (6, 9)], INK)
    return c.render()


def st_insane():
    c = Canvas(12, 12)
    c.ellipse(6, 6, 5.5, 5.5, 'purple', shade='sphere')
    for (x, y) in ((6, 6), (7, 6), (7, 5), (6, 4), (5, 4), (4, 5), (4, 7), (5, 8), (7, 8), (8, 7), (9, 5), (8, 3)):
        c.dot(x, y, '#f0d0ff')
    return c.render()


def st_hunger():
    c = Canvas(12, 12)
    c.ellipse(6, 7, 5, 3.6, 'wood', shade='sphere')
    c.line([(1, 1), (10, 10)], 'red', width=1)
    c.line([(10, 1), (1, 10)], 'red', width=1)
    return c.render()


def st_curse():
    c = Canvas(12, 12)
    c.ellipse(6, 6, 5.5, 4, 'black', shade='flat')
    c.ellipse(6, 6, 3, 3, 'demon', shade='sphere')
    c.rect(5, 4, 2, 4, 'black', shade='flat')
    c.dots([(0, 6), (11, 6)], ramp('demon', 2))
    return c.render()


def st_tumor():
    c = Canvas(12, 12)
    c.ellipse(5, 7, 4, 4, 'flesh', shade='sphere')
    c.ellipse(8.5, 4, 3, 3, 'flesh2', shade='sphere')
    c.ellipse(9, 9, 2, 2, 'pus', shade='sphere')
    return c.render()


def st_hallu():
    c = Canvas(12, 12)
    c.ellipse(6, 6, 5.5, 3.6, 'pink', shade='flat')
    c.ellipse(6, 6, 2.2, 2.2, 'teal', shade='flat')
    c.dot(6, 6, INK)
    c.dots([(0, 1), (11, 2), (1, 11), (10, 10)], ramp('yellow', 3))
    return c.render()


# buffs
def st_defend():
    c = Canvas(12, 12)
    c.poly([(1, 1), (10, 1), (10, 6), (6, 11), (1, 6)], 'blue', shade='edge')
    c.rect(5, 2, 2, 7, 'yellow', shade='flat')
    c.rect(3, 4, 6, 2, 'yellow', shade='flat')
    return c.render()


def st_bloodlust():
    c = Canvas(12, 12)
    c.poly([(1, 1), (5, 1), (4, 10)], 'bone', shade='edge')
    c.poly([(7, 1), (11, 1), (8, 10)], 'bone', shade='edge')
    c.dots([(4, 10), (4, 11), (8, 10), (8, 11)], ramp('red', 2))
    return c.render()


def st_focus():
    c = Canvas(12, 12)
    c.ellipse(6, 6, 5.5, 5.5, 'red', shade='flat')
    c.ellipse(6, 6, 3.6, 3.6, 'white', shade='flat')
    c.ellipse(6, 6, 1.8, 1.8, 'red', shade='flat')
    return c.render()


def st_regen():
    c = Canvas(12, 12)
    c.rect(4, 1, 4, 10, 'green', shade='edge')
    c.rect(1, 4, 10, 4, 'green', shade='edge')
    c.dots([(5, 2), (2, 5)], ramp('green', 3))
    return c.render()


def st_blessed():
    c = Canvas(12, 12)
    c.ellipse(6, 3, 5, 2, 'gold', shade='flat')
    c.ellipse(6, 3, 3, 1, 'gold', shade='outline')
    c.poly([(6, 5), (9, 8), (6, 11), (3, 8)], 'yellow', shade='edge')
    return c.render()


def st_adren():
    c = Canvas(12, 12)
    c.poly([(7, 0), (2, 7), (6, 7), (4, 11), (10, 4), (6, 4)], 'yellow', shade='edge')
    return c.render()


def st_haste():
    c = Canvas(12, 12)
    c.poly([(2, 3), (9, 3), (11, 6), (9, 9), (2, 9)], 'teal', shade='edge')
    c.dots([(0, 4), (0, 6), (0, 8)], ramp('teal', 3))
    return c.render()


STATUS = {
    'bleed': st_bleed, 'infect': st_infect, 'frac_arm': st_fracture_arm, 'frac_leg': st_fracture_leg,
    'stun': st_stun, 'poison': st_poison, 'toxic': st_toxic, 'parasite': st_parasite, 'blind': st_blind,
    'trauma': st_trauma, 'burn': st_burn, 'def_down': st_defdown, 'silence': st_silence, 'fear': st_fear,
    'insane': st_insane, 'hunger': st_hunger, 'curse': st_curse, 'tumor': st_tumor, 'hallu': st_hallu,
    'defend': st_defend, 'bloodlust': st_bloodlust, 'focus': st_focus, 'regen': st_regen,
    'blessed': st_blessed, 'adren': st_adren, 'haste': st_haste,
}


# =============================================================== stat icons 10x10
def ic_heart():
    c = Canvas(10, 10)
    c.ellipse(3, 3.5, 2.6, 2.6, 'red', shade='sphere'); c.ellipse(7, 3.5, 2.6, 2.6, 'red', shade='sphere')
    c.poly([(1, 4), (9, 4), (5, 9)], 'red', shade='edge')
    c.dot(2, 2, ramp('red', 3))
    return c.render(outline=False)


def ic_brain():
    c = Canvas(10, 10)
    c.ellipse(5, 5, 4.6, 4, 'pink', shade='sphere')
    c.dots([(5, 2), (5, 3), (4, 4), (5, 5), (5, 6), (3, 6), (7, 4), (6, 7)], ramp('pink', 1))
    return c.render(outline=False)


def ic_stomach():
    c = Canvas(10, 10)
    c.ellipse(5, 6, 4.6, 3.4, 'wood', shade='sphere')
    c.ellipse(5, 4.5, 4, 2.5, 'orange', shade='sphere')
    c.dots([(3, 4), (6, 4)], ramp('orange', 3))
    return c.render(outline=False)


def ic_coin():
    c = Canvas(10, 10)
    c.ellipse(5, 5, 4.4, 4.4, 'gold', shade='sphere')
    c.dots([(5, 3), (5, 4), (5, 5), (5, 6), (5, 7)], ramp('gold', 1))
    return c.render(outline=False)


def ic_sword():
    c = Canvas(10, 10)
    c.line([(2, 7), (8, 1)], 'metal', width=1, shade='light')
    c.line([(1, 6), (4, 9)], 'gold', width=1)
    c.dots([(1, 9), (0, 9)], ramp('wood', 2))
    return c.render(outline=False)


def ic_shield():
    c = Canvas(10, 10)
    c.poly([(1, 1), (8, 1), (8, 5), (4.5, 9), (1, 5)], 'blue', shade='edge')
    c.dots([(4, 2), (4, 3), (4, 4), (4, 5), (5, 2), (5, 3), (5, 4), (5, 5)], ramp('blue', 3))
    return c.render(outline=False)


def ic_boot():
    c = Canvas(10, 10)
    c.poly([(2, 1), (5, 1), (5, 5), (9, 6), (9, 9), (1, 9)], 'teal', shade='edge')
    return c.render(outline=False)


def ic_clover():
    c = Canvas(10, 10)
    for (x, y) in ((5, 2.5), (2.5, 5), (7.5, 5), (5, 7.5)):
        c.ellipse(x, y, 2.2, 2.2, 'green', shade='sphere')
    c.dot(5, 5, ramp('green', 1))
    return c.render(outline=False)


def ic_star():
    c = Canvas(10, 10)
    c.poly([(5, 0), (6, 3), (9, 3), (7, 5), (8, 9), (5, 7), (2, 9), (3, 5), (0, 3), (4, 3)], 'yellow', shade='edge')
    return c.render(outline=False)


def ic_dice():
    c = Canvas(10, 10)
    c.rrect(0, 0, 10, 10, 'white', shade='edge')
    c.dots([(2, 2), (5, 5), (7, 7)], ramp('red', 2))
    return c.render(outline=False)


def ic_skull():
    c = Canvas(10, 10)
    c.ellipse(5, 4, 4, 3.6, 'bone', shade='sphere')
    c.rect(3, 7, 4, 2, 'bone', shade='flat')
    c.dots([(3, 4), (6, 4)], INK)
    return c.render(outline=False)


STATICONS = {
    'hp': ic_heart, 'mind': ic_brain, 'hunger': ic_stomach, 'gold': ic_coin, 'atk': ic_sword,
    'def': ic_shield, 'agi': ic_boot, 'luck': ic_clover, 'exp': ic_star, 'dice': ic_dice, 'skull': ic_skull,
}


# =============================================================== dice 24x24
PIPS = {
    1: [(1, 1)], 2: [(0, 0), (2, 2)], 3: [(0, 0), (1, 1), (2, 2)], 4: [(0, 0), (2, 0), (0, 2), (2, 2)],
    5: [(0, 0), (2, 0), (1, 1), (0, 2), (2, 2)], 6: [(0, 0), (2, 0), (0, 1), (2, 1), (0, 2), (2, 2)],
}


def die(n, mat='white', pip='red'):
    c = Canvas(24, 24)
    c.rrect(1, 1, 22, 22, mat, shade='edge')
    c.rect(2, 2, 20, 1, mat, shade='light')
    for (i, j) in PIPS[n]:
        cx, cy = 6 + i * 6, 6 + j * 6
        col = ramp('red', 2) if n == 1 else ramp(pip, 1)
        for (x, y) in ((cx, cy), (cx + 1, cy), (cx, cy + 1), (cx + 1, cy + 1)):
            c.dot(x, y, col)
        c.dot(cx, cy, ramp(pip, 0) if n != 1 else ramp('red', 3))
    return c.render()


def die_blur():
    c = Canvas(24, 24)
    c.rrect(1, 1, 22, 22, 'white', shade='edge')
    for k in range(4):
        c.dots([(5 + k * 4, 6 + (k % 2) * 6), (6 + k * 4, 12 + (k % 2) * 4)], ramp('red', 1))
    return c.render()


# =============================================================== board tiles 32x32
STAGE_PAL = {
    1: dict(plate='stone', accent='yellow', ground=('#15161f', '#1c1e2a', '#232636'), glow='#e8c42a'),
    2: dict(plate='black', accent='lava', ground=('#120509', '#1c080e', '#2a0c12'), glow='#e04a10'),
    3: dict(plate='flesh2', accent='pus', ground=('#1a0710', '#240a16', '#33101e'), glow='#d2c242'),
}


def plate(stage, seed=0):
    rnd = random.Random(seed * 31 + stage)
    p = STAGE_PAL[stage]
    c = Canvas(32, 32)
    c.rrect(2, 3, 28, 27, p['plate'], shade='dark')       # side (thickness)
    c.rrect(2, 2, 28, 26, p['plate'], shade='flat')        # top face
    img = c.render(outline=True)
    px = img.load()
    base = ramp(p['plate'], 2)
    hi = ramp(p['plate'], 3)
    sh = ramp(p['plate'], 1)
    # top bevel
    for x in range(3, 29):
        px[x, 2] = hi
    for y in range(3, 27):
        px[2, y] = hi
    # texture per stage
    if stage == 1:     # cracked concrete
        for _ in range(9):
            x, y = rnd.randint(4, 27), rnd.randint(4, 25)
            px[x, y] = sh
        for k in range(5):
            px[20 + k, 6 + k // 2] = sh
    elif stage == 2:   # obsidian with lava cracks
        for x in range(3, 29):
            for y in range(3, 27):
                if rnd.random() < 0.05:
                    px[x, y] = hi
        cx, cy = rnd.randint(8, 22), 5
        for k in range(8):
            px[min(28, max(3, cx)), min(26, cy)] = ramp('lava', 2)
            cx += rnd.choice((-1, 0, 1)); cy += 1
    else:              # flesh with veins
        for x in range(3, 29):
            for y in range(3, 27):
                if rnd.random() < 0.04:
                    px[x, y] = ramp('flesh', 3)
        cx, cy = 4, rnd.randint(8, 20)
        for k in range(22):
            px[min(28, cx), min(26, max(3, cy))] = ramp('vein', 2)
            cx += 1; cy += rnd.choice((-1, 0, 0, 1))
    return img


def rim():
    """white rim overlay (modulated in engine by tile-type colour)"""
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    px = img.load()
    for x in range(3, 29):
        for y in (3, 4, 25, 26):
            px[x, y] = (255, 255, 255, 255)
    for y in range(3, 27):
        for x in (3, 4, 27, 28):
            px[x, y] = (255, 255, 255, 255)
    for (x, y) in ((3, 3), (28, 3), (3, 26), (28, 26)):
        px[x, y] = (0, 0, 0, 0)
    return img


def fog_tile():
    c = Canvas(32, 32)
    c.rrect(2, 3, 28, 27, 'shadow', shade='dark')
    c.rrect(2, 2, 28, 26, 'shadow', shade='flat')
    img = c.render()
    px = img.load()
    for (x, y) in ((14, 9), (15, 8), (16, 8), (17, 8), (18, 9), (18, 10), (17, 11), (16, 12), (16, 13), (16, 16)):
        px[x, y] = hx('#5a4a78')
    return img


# --- tile type icons 16x16
def ti_start():
    c = Canvas(16, 16)
    c.rect(4, 1, 1, 14, 'wood', shade='flat')
    c.poly([(5, 1), (14, 4), (5, 8)], 'green', shade='edge')
    c.rect(2, 14, 6, 2, 'stone', shade='flat')
    return c.render()


def ti_enemy():
    c = Canvas(16, 16)
    c.line([(2, 2), (13, 13)], 'metal', width=2)
    c.line([(13, 2), (2, 13)], 'metal', width=2)
    c.ellipse(8, 8, 3.6, 3.4, 'bone', shade='sphere')
    c.dots([(7, 8), (9, 8)], INK)
    c.dots([(1, 13), (2, 14), (14, 13), (13, 14)], ramp('red', 2))
    return c.render()


def ti_elite():
    c = Canvas(16, 16)
    c.ellipse(8, 8, 5.5, 5, 'bone', shade='sphere')
    c.rect(5, 11, 6, 3, 'bone', shade='edge')
    c.poly([(3, 6), (0, 0), (5, 3)], 'red', shade='edge')
    c.poly([(13, 6), (16, 0), (11, 3)], 'red', shade='edge')
    c.dots([(5, 8), (6, 8), (10, 8), (11, 8)], '#ff6020')
    c.dots([(6, 13), (8, 13), (10, 13)], INK)
    return c.render()


def ti_boss():
    c = Canvas(16, 16)
    c.ellipse(8, 9, 6.5, 5.5, 'bone', shade='sphere')
    c.rect(4, 12, 8, 3, 'bone', shade='edge')
    c.poly([(2, 5), (3, 0), (6, 3), (8, 0), (10, 3), (13, 0), (14, 5)], 'gold', shade='edge')
    c.dots([(5, 9), (6, 9), (5, 10), (10, 9), (11, 9), (11, 10)], '#ff2020')
    c.dots([(6, 14), (8, 14), (10, 14)], INK)
    return c.render()


def ti_treasure():
    c = Canvas(16, 16)
    c.rrect(1, 7, 14, 8, 'wood', shade='edge')
    c.poly([(1, 7), (3, 3), (13, 3), (15, 7)], 'wood', shade='edge')
    c.rect(1, 7, 14, 1, 'gold', shade='flat')
    c.rect(7, 6, 3, 4, 'gold', shade='edge')
    c.dots([(2, 2), (12, 1), (14, 3)], ramp('yellow', 3))
    return c.render()


def ti_item():
    c = Canvas(16, 16)
    c.ellipse(8, 10, 6, 5, 'khaki', shade='sphere')
    c.poly([(5, 5), (11, 5), (12, 2), (4, 2)], 'khaki', shade='edge')
    c.rect(5, 5, 6, 1, 'red', shade='flat')
    c.dots([(7, 10), (8, 9), (9, 10), (8, 11)], ramp('yellow', 3))
    return c.render()


def ti_merchant():
    c = Canvas(16, 16)
    c.poly([(0, 6), (8, 1), (16, 6)], 'red', shade='edge')
    c.dots([(3, 5), (7, 5), (11, 5)], ramp('white', 2))
    c.rect(2, 6, 12, 7, 'wood', shade='edge')
    c.rect(4, 8, 8, 3, 'black', shade='flat')
    c.ellipse(6, 9.5, 1.5, 1.5, 'gold', shade='flat'); c.ellipse(10, 9.5, 1.5, 1.5, 'green', shade='flat')
    c.ellipse(4, 14, 1.6, 1.6, 'black', shade='flat'); c.ellipse(12, 14, 1.6, 1.6, 'black', shade='flat')
    return c.render()


def ti_trap():
    c = Canvas(16, 16)
    c.ellipse(8, 11, 7, 3, 'metal', shade='flat')
    c.ellipse(8, 11, 4.5, 1.6, 'black', shade='flat')
    for x in (2, 5, 8, 11, 14):
        c.poly([(x - 1, 10), (x, 4), (x + 1, 10)], 'metal', shade='edge')
    c.dots([(5, 5), (11, 5)], ramp('red', 2))
    return c.render()


def ti_event():
    c = Canvas(16, 16)
    c.stamp(3, 1, [
        ".qqqqqq...",
        "qqqqqqqq..",
        "qqq..qqq..",
        ".....qqq..",
        "....qqq...",
        "...qqq....",
        "...qq.....",
        "..........",
        "...qq.....",
        "...qq.....",
    ], {'q': 'purple'}, shade='edge')
    return c.render()


def ti_rest():
    c = Canvas(16, 16)
    c.line([(2, 14), (14, 11)], 'wood', width=2)
    c.line([(2, 11), (14, 14)], 'wood', width=2)
    c.poly([(8, 1), (12, 7), (11, 11), (5, 11), (4, 7), (6, 5)], 'fire', shade='edge')
    c.poly([(8, 6), (10, 9), (8, 11), (6, 9)], 'yellow', shade='flat')
    return c.render()


def ti_shrine():
    c = Canvas(16, 16)
    c.rect(2, 11, 12, 4, 'stone', shade='edge')
    c.rect(4, 7, 8, 4, 'stone', shade='edge')
    c.rect(7, 3, 2, 4, 'cloth', shade='flat')
    c.poly([(8, 0), (9, 2), (8, 3), (7, 2)], 'fire', shade='flat')
    c.dots([(5, 9), (10, 9)], ramp('gold', 3))
    return c.render()


def ti_warp():
    c = Canvas(16, 16)
    c.ellipse(8, 8, 7, 7, 'purple', shade='flat')
    c.ellipse(8, 8, 5, 5, 'blue', shade='flat')
    c.ellipse(8, 8, 3, 3, 'teal', shade='flat')
    c.ellipse(8, 8, 1.4, 1.4, 'white', shade='flat')
    for (x, y) in ((3, 4), (12, 11), (11, 3)):
        c.dot(x, y, W)
    return c.render()


def ti_gate():
    c = Canvas(16, 16)
    c.rect(1, 2, 3, 14, 'stone', shade='edge'); c.rect(12, 2, 3, 14, 'stone', shade='edge')
    c.rect(1, 1, 14, 3, 'stone', shade='edge')
    c.rect(4, 4, 8, 12, 'purple', shade='flat')
    c.ellipse(8, 10, 3, 4.5, 'pink', shade='flat')
    c.ellipse(8, 10, 1.4, 2.4, 'white', shade='flat')
    return c.render()


def ti_cleared():
    c = Canvas(16, 16)
    c.ellipse(8, 8, 2, 2, 'stone', shade='flat')
    return c.render(outline=False)


TILE_ICONS = {
    'start': ti_start, 'enemy': ti_enemy, 'elite': ti_elite, 'boss': ti_boss, 'treasure': ti_treasure,
    'item': ti_item, 'merchant': ti_merchant, 'trap': ti_trap, 'event': ti_event, 'rest': ti_rest,
    'shrine': ti_shrine, 'warp': ti_warp, 'gate': ti_gate, 'cleared': ti_cleared,
}


# =============================================================== ground textures 64x64 (tileable)
def ground(stage):
    rnd = random.Random(stage * 97)
    g = STAGE_PAL[stage]['ground']
    img = Image.new('RGBA', (64, 64), hx(g[1]))
    px = img.load()
    for y in range(64):
        for x in range(64):
            r = rnd.random()
            if r < 0.10:
                px[x, y] = hx(g[0])
            elif r < 0.16:
                px[x, y] = hx(g[2])
    if stage == 1:   # faint brick/pavement grid
        for y in range(0, 64, 16):
            for x in range(64):
                px[x, y] = hx(g[0])
        for y in range(64):
            off = 0 if (y // 16) % 2 == 0 else 16
            for x in range(off, 64, 32):
                px[x, y] = hx(g[0])
    elif stage == 2:  # ember specks
        for _ in range(14):
            px[rnd.randrange(64), rnd.randrange(64)] = hx('#5a1206')
        for _ in range(4):
            px[rnd.randrange(64), rnd.randrange(64)] = hx('#c03a0c')
    else:             # veins network
        for _ in range(3):
            x, y = rnd.randrange(64), rnd.randrange(64)
            for k in range(40):
                px[x % 64, y % 64] = hx('#4a0a24')
                x += rnd.choice((1, 1, 0)); y += rnd.choice((-1, 0, 1))
    return img


# =============================================================== props 32x32
def prop_lamp():
    c = Canvas(32, 32)
    c.rect(15, 6, 2, 24, 'black', shade='edge_soft')
    c.rect(12, 29, 8, 2, 'black', shade='flat')
    c.rect(15, 5, 7, 2, 'black', shade='flat')
    c.rrect(19, 6, 5, 3, 'yellow', shade='light')
    img = c.render()
    return img


def prop_trash():
    c = Canvas(32, 32)
    c.rrect(9, 14, 14, 16, 'green', shade='edge')
    c.rect(8, 12, 16, 3, 'green', shade='edge')
    for x in (12, 16, 20):
        c.rect(x, 16, 1, 12, 'green', shade='dark')
    c.ellipse(6, 28, 3, 2, 'khaki', shade='sphere')
    c.dots([(24, 29), (26, 28)], ramp('paper', 2))
    return c.render()


def prop_building():
    c = Canvas(32, 32)
    c.rect(4, 4, 24, 27, 'navy', shade='edge')
    c.rect(3, 3, 26, 2, 'stone', shade='flat')
    for y in (7, 14, 21):
        for x in (7, 14, 21):
            lit = (x * y) % 3 == 0
            c.rect(x, y, 4, 4, 'yellow' if lit else 'black', shade='flat')
    c.rect(13, 25, 6, 6, 'black', shade='flat')
    return c.render()


def prop_cone():
    c = Canvas(32, 32)
    c.poly([(16, 14), (21, 28), (11, 28)], 'orange', shade='edge')
    c.rect(13, 21, 6, 2, 'white', shade='flat')
    c.rect(9, 28, 14, 2, 'black', shade='flat')
    return c.render()


def prop_lava():
    c = Canvas(32, 32)
    c.ellipse(16, 22, 12, 7, 'black', shade='flat')
    c.ellipse(16, 22, 10, 5, 'lava', shade='sphere')
    c.dots([(12, 21), (18, 23), (21, 20)], ramp('yellow', 3))
    return c.render()


def prop_bones():
    c = Canvas(32, 32)
    c.ellipse(16, 25, 10, 4, 'bone', shade='sphere')
    c.ellipse(14, 19, 4, 3.6, 'bone', shade='sphere')
    c.dots([(13, 19), (15, 19)], INK)
    c.line([(20, 20), (27, 24)], 'bone', width=2)
    c.line([(5, 24), (10, 21)], 'bone', width=2)
    return c.render()


def prop_spike():
    c = Canvas(32, 32)
    c.poly([(14, 29), (16, 4), (18, 29)], 'black', shade='edge')
    c.ellipse(16, 12, 3, 3, 'bone', shade='sphere')
    c.dots([(15, 12), (17, 12)], '#ff3020')
    c.rect(11, 28, 10, 3, 'stone', shade='edge')
    return c.render()


def prop_deadtree():
    c = Canvas(32, 32)
    c.rect(15, 12, 3, 19, 'brown', shade='edge')
    c.line([(16, 14), (9, 6), (6, 6)], 'brown', width=2)
    c.line([(17, 16), (24, 8), (26, 4)], 'brown', width=2)
    c.line([(12, 9), (12, 3)], 'brown', width=1)
    return c.render()


def prop_vein():
    c = Canvas(32, 32)
    c.line([(4, 30), (10, 22), (9, 14), (14, 6)], 'vein', width=3)
    c.line([(10, 22), (20, 20), (27, 12)], 'vein', width=2)
    c.ellipse(14, 6, 3, 3, 'flesh', shade='sphere')
    c.ellipse(27, 12, 2.4, 2.4, 'pus', shade='sphere')
    return c.render()


def prop_eyestalk():
    c = Canvas(32, 32)
    c.line([(16, 30), (15, 20), (17, 12)], 'flesh2', width=3)
    c.ellipse(17, 9, 5, 5, 'eye', shade='sphere')
    c.ellipse(17, 9.5, 2.5, 2.5, 'teal', shade='flat')
    c.dot(17, 9, INK)
    c.ellipse(16, 29, 6, 2.5, 'flesh', shade='sphere')
    return c.render()


def prop_pustule():
    c = Canvas(32, 32)
    c.ellipse(16, 24, 11, 6, 'flesh', shade='sphere')
    c.ellipse(12, 20, 4, 4, 'pus', shade='sphere')
    c.ellipse(20, 21, 3, 3, 'pus', shade='sphere')
    c.ellipse(16, 17, 2.4, 2.4, 'pus', shade='sphere')
    return c.render()


def prop_teeth():
    c = Canvas(32, 32)
    c.ellipse(16, 27, 12, 4, 'flesh2', shade='sphere')
    for (x, h) in ((8, 8), (13, 12), (18, 10), (23, 7)):
        c.poly([(x - 2, 27), (x, 27 - h), (x + 2, 27)], 'bone', shade='edge')
    return c.render()


PROPS = {
    1: {'lamp': prop_lamp, 'trash': prop_trash, 'building': prop_building, 'cone': prop_cone},
    2: {'lava': prop_lava, 'bones': prop_bones, 'spike': prop_spike, 'deadtree': prop_deadtree},
    3: {'vein': prop_vein, 'eyestalk': prop_eyestalk, 'pustule': prop_pustule, 'teeth': prop_teeth},
}


# =============================================================== UI 9-slice
def panel(fill='#16121f', rim='#4d3f63', hi='#7a6a94', dark='#07050b', rivet='#b8a27a', size=24):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size - 1
    d.rectangle([1, 0, s - 1, s], fill=hx(dark))
    d.rectangle([0, 1, s, s - 1], fill=hx(dark))
    d.rectangle([1, 1, s - 1, s - 1], fill=hx(rim))
    d.rectangle([2, 2, s - 2, s - 2], fill=hx(dark))
    d.rectangle([3, 3, s - 3, s - 3], fill=hx(fill))
    px = img.load()
    for x in range(2, s - 1):
        px[x, 1] = hx(hi)
    for y in range(2, s - 1):
        px[1, y] = hx(hi)
    # rivets
    for (x, y) in ((3, 3), (s - 3, 3), (3, s - 3), (s - 3, s - 3)):
        px[x, y] = hx(rivet)
    # subtle inner top shine
    for x in range(4, s - 3):
        px[x, 3] = hx('#1f1a2c')
    return img


def button(state):
    pal = {
        'normal':   ('#2a2238', '#5c4c74', '#8a7aa6', '#0a0710'),
        'hover':    ('#3a2c4a', '#c8941e', '#ffd86a', '#0a0710'),
        'pressed':  ('#1a1424', '#8a6418', '#c8941e', '#0a0710'),
        'disabled': ('#1c1a22', '#34303e', '#44404e', '#0a0710'),
        'focus':    ('#00000000', '#ffd86a', '#ffd86a', '#00000000'),
    }[state]
    fill, rim, hi, dark = pal
    img = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if state == 'focus':
        d.rectangle([0, 0, 15, 15], outline=hx(rim))
        img.putpixel((0, 0), (0, 0, 0, 0)); img.putpixel((15, 0), (0, 0, 0, 0))
        img.putpixel((0, 15), (0, 0, 0, 0)); img.putpixel((15, 15), (0, 0, 0, 0))
        return img
    d.rectangle([1, 0, 14, 15], fill=hx(dark))
    d.rectangle([0, 1, 15, 14], fill=hx(dark))
    d.rectangle([1, 1, 14, 14], fill=hx(rim))
    d.rectangle([2, 2, 13, 13], fill=hx(fill))
    px = img.load()
    if state != 'pressed':
        for x in range(2, 14):
            px[x, 2] = hx(hi)
        for x in range(2, 14):
            px[x, 13] = hx(dark)
    else:
        for x in range(2, 14):
            px[x, 2] = hx(dark)
    return img


def slot(state='normal'):
    fill = {'normal': '#120f19', 'hover': '#2a2238', 'equip': '#2a2410'}[state]
    rim = {'normal': '#3a3048', 'hover': '#c8941e', 'equip': '#dca424'}[state]
    img = Image.new('RGBA', (20, 20), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, 19, 19], fill=hx('#07050b'))
    d.rectangle([1, 1, 18, 18], fill=hx(rim))
    d.rectangle([2, 2, 17, 17], fill=hx(fill))
    px = img.load()
    for x in range(2, 18):
        px[x, 2] = hx('#07050b')
    for y in range(2, 18):
        px[2, y] = hx('#07050b')
    return img


def bar_frame():
    img = Image.new('RGBA', (8, 8), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, 7, 7], fill=hx('#07050b'))
    d.rectangle([1, 1, 6, 6], fill=hx('#1c1724'))
    return img


def arrow_down():
    c = Canvas(9, 7)
    c.poly([(0, 0), (8, 0), (4, 5)], 'yellow', shade='edge')
    return c.render()


def arrow_right():
    c = Canvas(14, 14)
    c.poly([(1, 4), (7, 4), (7, 0), (13, 6), (7, 12), (7, 8), (1, 8)], 'yellow', shade='edge')
    return c.render()


def cursor_hand():
    c = Canvas(12, 12)
    c.stamp(0, 0, [
        "w.........",
        "ww........",
        "wyw.......",
        "wyyw......",
        "wyyyw.....",
        "wyyyyw....",
        "wyyyyyw...",
        "wyyyww....",
        "wwyyw.....",
        "...wyw....",
        "....w.....",
    ], {'w': 'black', 'y': 'yellow'}, shade='flat')
    return c.render(outline=False)


def shadow_blob(w=20, h=6):
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            dx = (x + 0.5 - w / 2) / (w / 2)
            dy = (y + 0.5 - h / 2) / (h / 2)
            if dx * dx + dy * dy <= 1:
                px[x, y] = (8, 4, 14, 120)
    return img


# =============================================================== VFX frames
def vfx_slash(frame):
    """crescent swipe: grows over 2 frames then thins out"""
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    px = img.load()
    sweep = [0.45, 1.0, 1.0, 1.0][frame]
    thick = [2.2, 3.4, 2.2, 1.0][frame]
    for y in range(32):
        for x in range(32):
            dx, dy = x + 0.5 - 12, y + 0.5 - 20
            r = math.hypot(dx, dy)
            a = math.atan2(-dy, dx)            # 0 = right, pi/2 = up
            t = (a + 0.2) / 1.9                # 0..1 along the arc
            if 0 <= t <= sweep:
                w = thick * math.sin(math.pi * min(1, t / max(sweep, 0.01)))
                if 13 - w <= r <= 13 + w * 0.5:
                    edge = r > 13 - w * 0.4
                    px[x, y] = hx('#ffffff') if edge else hx('#ffd86a') if frame < 3 else hx('#c8941e')
    return img


def vfx_blood(frame):
    rnd = random.Random(7)
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    px = img.load()
    for i in range(18):
        ang = rnd.random() * math.tau
        sp = 3 + rnd.random() * 10
        r = sp * (frame + 1) / 4
        x = int(16 + math.cos(ang) * r)
        y = int(16 + math.sin(ang) * r + frame * frame * 0.6)
        if 0 <= x < 31 and 0 <= y < 31:
            col = hx('#b02a32') if i % 3 else hx('#e85a42')
            px[x, y] = col
            if frame < 2:
                px[x + 1, y] = hx('#6e1424')
    return img


def vfx_spark(frame):
    c = Canvas(32, 32)
    r = 3 + frame * 4
    for k in range(8):
        a = k * math.pi / 4
        for t in range(2):
            x = int(16 + math.cos(a) * (r + t * 2))
            y = int(16 + math.sin(a) * (r + t * 2))
            c.dot(x, y, '#fff4a0' if t == 0 else '#ffb030')
    if frame == 0:
        c.ellipse(16, 16, 4, 4, 'yellow', shade='light')
    return c.render(outline=False)


def vfx_fire(frame):
    rnd = random.Random(frame * 13 + 1)
    c = Canvas(32, 32)
    h = [10, 16, 20, 14][frame]
    c.poly([(8, 30), (10, 30 - h * 0.6), (13, 30 - h), (16, 30 - h * 0.7), (19, 30 - h * 1.1), (22, 30 - h * 0.5), (24, 30)], 'fire', shade='edge')
    c.poly([(12, 30), (14, 30 - h * 0.5), (16, 30 - h * 0.35), (18, 30 - h * 0.6), (20, 30)], 'yellow', shade='flat')
    for _ in range(4):
        c.dot(rnd.randint(8, 24), rnd.randint(2, 20), '#ffe060')
    return c.render(outline=False)


def vfx_poison(frame):
    rnd = random.Random(3)
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    px = img.load()
    for i in range(10):
        x0, y0 = rnd.randint(6, 26), rnd.randint(14, 28)
        y = y0 - frame * 4
        r = 1 + (i % 2)
        for dx in range(-r, r + 1):
            for dy in range(-r, r + 1):
                if dx * dx + dy * dy <= r * r and 0 <= x0 + dx < 32 and 0 <= y + dy < 32:
                    px[x0 + dx, y + dy] = hx('#5ca83c') if (dx + dy) % 2 else hx('#a8e272')
    return img


def vfx_heal(frame):
    rnd = random.Random(5)
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    px = img.load()
    for i in range(8):
        x, y0 = rnd.randint(4, 27), rnd.randint(12, 28)
        y = y0 - frame * 4
        for (dx, dy) in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
            if 0 <= x + dx < 32 and 0 <= y + dy < 32:
                px[x + dx, y + dy] = hx('#7ec45c') if (dx, dy) != (0, 0) else hx('#e8ffd0')
    return img


def vfx_dark(frame):
    c = Canvas(32, 32)
    r = 4 + frame * 3
    c.ellipse(16, 16, r, r, 'purple', shade='flat')
    if r > 4:
        c.ellipse(16, 16, r - 3, r - 3, 'shadow', shade='flat')
    return c.render(outline=False)


VFX = {
    'slash': (vfx_slash, 4), 'blood': (vfx_blood, 4), 'spark': (vfx_spark, 4), 'fire': (vfx_fire, 4),
    'poison': (vfx_poison, 4), 'heal': (vfx_heal, 4), 'dark': (vfx_dark, 4),
}
