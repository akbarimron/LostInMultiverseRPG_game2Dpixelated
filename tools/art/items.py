"""16x16 item icons: consumables, materials, money, weapons, armor, accessories."""
from pxlib import Canvas, ramp, hx

W = '#ffffff'


def C():
    return Canvas(16, 16)


# ---------------------------------------------------------------- consumables
def perban():
    c = C()
    c.ellipse(8, 8, 5.5, 5.5, 'cloth', shade='sphere')
    c.ellipse(8, 8, 2.2, 2.2, 'cloth', shade='dark')
    c.dot(8, 8, ramp('cloth', 0))
    c.poly([(11, 10), (15, 12), (14, 14), (10, 12)], 'cloth', shade='edge')
    c.dots([(5, 5), (6, 4)], ramp('red', 2))
    return c.render()


def obat_merah():
    c = C()
    c.rrect(5, 6, 6, 8, 'red', shade='edge')
    c.rect(6, 3, 4, 3, 'white', shade='edge')
    c.rect(6, 8, 4, 3, 'paper', shade='flat')
    c.dots([(8, 8), (7, 9), (8, 9), (9, 9), (8, 10)], ramp('red', 2))
    c.dot(6, 7, ramp('red', 3))
    return c.render()


def bidai():
    c = C()
    c.rect(3, 2, 3, 12, 'wood', shade='edge')
    c.rect(10, 2, 3, 12, 'wood', shade='edge')
    for y in (4, 8, 12):
        c.rect(2, y, 12, 2, 'cloth', shade='edge')
    return c.render()


def penawar():
    c = C()
    c.ellipse(8, 10, 4.5, 4.5, 'glass', shade='sphere')
    c.ellipse(8, 11, 3.5, 3, 'green', shade='sphere')
    c.rect(7, 3, 3, 4, 'glass', shade='edge')
    c.rect(6, 2, 5, 2, 'wood', shade='flat')
    c.dots([(6, 9)], W)
    return c.render()


def roti():
    c = C()
    c.ellipse(8, 9, 6.5, 4.5, 'orange', shade='sphere')
    c.ellipse(8, 7.5, 6, 3.5, 'wood', shade='sphere')
    c.dots([(5, 7), (8, 6), (11, 7)], ramp('wood', 3))
    c.dots([(5, 8), (8, 7), (11, 8)], ramp('wood', 1))
    return c.render()


def air():
    c = C()
    c.rrect(5, 4, 6, 11, 'glass', shade='edge')
    c.rect(6, 2, 4, 2, 'blue', shade='flat')
    c.rect(5, 8, 6, 3, 'blue', shade='flat')
    c.dots([(6, 5), (6, 6), (6, 12)], W)
    return c.render()


def kopi():
    c = C()
    c.rrect(3, 6, 8, 8, 'white', shade='edge')
    c.rect(4, 6, 6, 2, 'brown', shade='dark')
    c.ellipse(12, 10, 2.3, 2.6, 'white', shade='flat')
    c.erase_px([(12, 10)])
    c.dots([(5, 3), (6, 2), (8, 4), (9, 3)], ramp('white', 1))
    return c.render()


def jamu():
    c = C()
    c.ellipse(8, 10, 5.5, 4.5, 'brown', shade='sphere')
    c.rect(6, 4, 4, 3, 'brown', shade='edge')
    c.rect(5, 3, 6, 1, 'khaki', shade='flat')
    c.dots([(6, 10), (7, 11), (9, 9), (10, 10)], ramp('yellow', 2))
    c.dots([(4, 9)], ramp('brown', 3))
    return c.render()


def daging():
    c = C()
    c.ellipse(9, 8, 5.5, 4.5, 'flesh', shade='sphere')
    c.line([(4, 12), (2, 14)], 'bone', width=2)
    c.dots([(1, 14), (2, 15), (3, 15)], ramp('bone', 2))
    c.dots([(8, 7), (10, 9), (11, 6)], ramp('flesh', 3))
    c.dots([(7, 9), (12, 8)], ramp('slime', 2))
    return c.render()


def nasi():
    c = C()
    c.poly([(2, 9), (8, 4), (14, 9), (8, 14)], 'green', shade='edge')
    c.poly([(5, 9), (8, 6), (11, 9), (8, 12)], 'paper', shade='edge')
    c.dots([(8, 4), (8, 3)], ramp('green', 1))
    return c.render()


def batu():
    c = C()
    c.ellipse(8, 9.5, 5.5, 4.5, 'stone', shade='sphere')
    c.dots([(6, 9), (9, 11), (10, 8)], ramp('stone', 1))
    return c.render()


def molotov():
    c = C()
    c.ellipse(8, 11, 4, 4, 'glass', shade='sphere')
    c.ellipse(8, 12, 3, 2.5, 'orange', shade='flat')
    c.rect(7, 4, 3, 4, 'glass', shade='edge')
    c.rect(7, 2, 3, 3, 'cloth', shade='edge')
    c.poly([(7, 2), (8, 0), (10, 1), (10, 3)], 'fire', shade='flat')
    return c.render()


def garam():
    c = C()
    c.rrect(4, 5, 8, 10, 'white', shade='edge')
    c.rect(5, 2, 6, 3, 'metal', shade='edge')
    c.dots([(6, 3), (8, 3), (10, 3)], ramp('metal', 0))
    c.rect(5, 8, 6, 3, 'blue', shade='flat')
    c.dots([(6, 9), (7, 9), (8, 9), (9, 9)], W)
    return c.render()


def air_suci():
    c = C()
    c.ellipse(8, 10, 4.5, 4.5, 'glass', shade='sphere')
    c.rect(7, 3, 3, 4, 'glass', shade='edge')
    c.rect(6, 2, 5, 2, 'gold', shade='flat')
    c.dots([(8, 8), (7, 9), (8, 9), (9, 9), (8, 10), (8, 11)], ramp('yellow', 3))
    return c.render()


def obat_cacing():
    c = C()
    c.rrect(3, 4, 10, 9, 'white', shade='edge')
    c.rect(3, 4, 10, 3, 'teal', shade='flat')
    c.dots([(5, 9), (6, 10), (7, 9), (8, 10), (9, 9), (10, 10)], ramp('pink', 2))
    return c.render()


def obat_mata():
    c = C()
    c.rrect(6, 6, 5, 8, 'white', shade='edge')
    c.poly([(7, 6), (8, 1), (10, 6)], 'blue', shade='flat')
    c.ellipse(8.5, 10, 1.8, 1.4, 'blue', shade='flat')
    c.dot(8, 10, ramp('black', 0))
    return c.render()


def permen():
    c = C()
    c.ellipse(8, 8, 3.8, 3.8, 'pink', shade='sphere')
    c.poly([(4, 8), (1, 5), (1, 11)], 'pink', shade='flat')
    c.poly([(12, 8), (15, 5), (15, 11)], 'pink', shade='flat')
    c.dots([(7, 7), (9, 9)], W)
    return c.render()


def jimat():
    c = C()
    c.rrect(4, 3, 8, 11, 'paper', shade='edge')
    c.dots([(6, 5), (7, 5), (8, 5), (9, 5), (7, 6), (8, 7), (9, 8), (6, 9), (7, 9), (8, 10), (9, 11)], ramp('red', 2))
    c.dot(8, 2, ramp('red', 2)); c.dot(8, 1, ramp('red', 2))
    return c.render()


def dadu_emas():
    c = C()
    c.rrect(3, 3, 10, 10, 'gold', shade='edge')
    c.dots([(5, 5), (10, 10), (8, 8), (5, 10), (10, 5)], ramp('gold', 0))
    return c.render()


def kunci():
    c = C()
    c.ellipse(5, 6, 3.4, 3.4, 'gold', shade='sphere')
    c.erase_px([(5, 6)])
    c.rect(7, 6, 7, 2, 'gold', shade='edge')
    c.rect(11, 8, 1, 2, 'gold', shade='flat'); c.rect(13, 8, 1, 3, 'gold', shade='flat')
    return c.render()


def pisau_bedah_item():
    c = C()
    c.line([(3, 13), (8, 8)], 'teal', width=2)
    c.poly([(8, 8), (13, 2), (14, 3), (10, 9)], 'metal', shade='edge')
    return c.render()


def bom_asap():
    c = C()
    c.ellipse(8, 10, 5, 5, 'black', shade='sphere')
    c.rect(7, 3, 2, 3, 'metal', shade='flat')
    c.dots([(9, 2), (10, 1), (11, 1)], ramp('fire', 3))
    c.dots([(6, 8)], ramp('black', 3))
    return c.render()


# ---------------------------------------------------------------- materials
def kain():
    c = C()
    c.poly([(2, 4), (13, 3), (14, 12), (3, 13)], 'red', shade='edge')
    c.dots([(5, 6), (9, 8), (6, 10), (11, 5)], ramp('red', 1))
    c.dots([(3, 5), (4, 4)], ramp('red', 3))
    return c.render()


def kayu():
    c = C()
    c.poly([(2, 11), (11, 2), (14, 5), (5, 14)], 'wood', shade='edge')
    c.ellipse(12.5, 3.5, 2, 2, 'wood', shade='light')
    c.dot(12, 3, ramp('wood', 1))
    return c.render()


def besi():
    c = C()
    c.poly([(2, 10), (8, 5), (14, 8), (12, 13), (4, 13)], 'metal', shade='edge')
    c.dots([(6, 9), (9, 10), (11, 9)], ramp('rust', 2))
    c.dots([(7, 10), (10, 11)], ramp('rust', 1))
    return c.render()


def tali():
    c = C()
    c.ellipse(8, 8, 6, 5.5, 'khaki', shade='sphere')
    c.ellipse(8, 8, 3.5, 3, 'khaki', shade='dark')
    c.ellipse(8, 8, 1.6, 1.4, 'khaki', shade='outline')
    c.line([(12, 11), (15, 14)], 'khaki', width=1)
    return c.render()


def paku():
    c = C()
    for (x, y) in ((3, 4), (8, 3), (12, 6)):
        c.rect(x, y + 2, 1, 7, 'metal', shade='flat')
        c.rect(x - 1, y + 1, 3, 1, 'metal', shade='light')
        c.dot(x, y + 9, ramp('metal', 1))
    return c.render()


def botol():
    c = C()
    c.rrect(5, 6, 6, 9, 'green', shade='edge')
    c.rect(7, 2, 2, 4, 'green', shade='edge')
    c.dots([(6, 8), (6, 9)], ramp('glass', 3))
    return c.render()


def minyak():
    c = C()
    c.rrect(3, 4, 10, 11, 'yellow', shade='edge')
    c.rect(9, 1, 3, 3, 'red', shade='flat')
    c.rect(5, 7, 6, 4, 'red', shade='flat')
    c.dots([(7, 8), (8, 9)], ramp('yellow', 3))
    return c.render()


def herbal():
    c = C()
    c.line([(8, 15), (8, 6)], 'green', width=1)
    c.ellipse(5, 7, 3, 2, 'green', shade='sphere')
    c.ellipse(11, 5, 3, 2, 'green', shade='sphere')
    c.ellipse(6, 11, 2.6, 1.8, 'green', shade='sphere')
    c.ellipse(11, 10, 2.6, 1.8, 'green', shade='sphere')
    c.ellipse(8, 3, 1.6, 1.6, 'pink', shade='flat')
    return c.render()


def tanduk():
    c = C()
    c.poly([(3, 14), (5, 8), (9, 4), (13, 1), (11, 6), (8, 11), (7, 14)], 'bone', shade='edge')
    c.dots([(5, 11), (7, 8), (9, 6)], ramp('bone', 1))
    return c.render()


def batu_jiwa():
    c = C()
    c.poly([(8, 1), (13, 6), (8, 15), (3, 6)], 'purple', shade='edge')
    c.poly([(8, 3), (11, 6), (8, 12), (5, 6)], 'pink', shade='flat')
    c.dots([(6, 5), (7, 4)], W)
    return c.render()


def daging_tumor():
    c = C()
    c.ellipse(8, 9, 6, 5, 'flesh', shade='sphere')
    c.ellipse(11, 6, 3, 3, 'flesh2', shade='sphere')
    c.ellipse(5, 11, 2, 2, 'pus', shade='sphere')
    c.ellipse(11, 6, 1.4, 1.4, 'eye', shade='flat')
    c.dot(11, 6, '#140c1c')
    return c.render()


def taring():
    c = C()
    c.poly([(4, 2), (8, 2), (7, 9), (5, 14)], 'bone', shade='edge')
    c.poly([(9, 3), (13, 3), (12, 8), (11, 11)], 'bone', shade='edge')
    return c.render()


# ---------------------------------------------------------------- money
def koin():
    c = C()
    c.ellipse(8, 8, 5.5, 5.5, 'gold', shade='sphere')
    c.ellipse(8, 8, 3.5, 3.5, 'gold', shade='dark')
    c.dots([(8, 6), (8, 7), (8, 8), (8, 9), (8, 10), (7, 7), (9, 9)], ramp('gold', 3))
    return c.render()


def uang():
    c = C()
    c.rect(1, 5, 14, 7, 'green', shade='edge')
    c.rect(2, 3, 14, 7, 'green', shade='edge')
    c.ellipse(9, 6.5, 2, 2, 'green', shade='dark')
    c.dots([(3, 4), (14, 8)], ramp('green', 3))
    return c.render()


def kantong():
    c = C()
    c.ellipse(8, 10, 6, 5, 'khaki', shade='sphere')
    c.poly([(6, 5), (10, 5), (11, 3), (5, 3)], 'khaki', shade='edge')
    c.rect(5, 5, 6, 1, 'red', shade='flat')
    c.dots([(7, 9), (8, 9), (9, 9), (8, 8), (8, 10), (8, 11)], ramp('gold', 3))
    return c.render()


def emas():
    c = C()
    c.poly([(1, 13), (4, 8), (12, 8), (15, 13)], 'gold', shade='edge')
    c.poly([(4, 8), (6, 4), (11, 4), (12, 8)], 'gold', shade='edge')
    c.dots([(6, 5), (5, 9)], W)
    return c.render()


# ---------------------------------------------------------------- weapons (diagonal, handle bottom-left)
def tangan():
    c = C()
    c.ellipse(8, 9, 4.5, 4, 'skin', shade='sphere')
    c.rect(4, 5, 8, 3, 'skin', shade='edge')
    c.dots([(6, 6), (8, 6), (10, 6)], ramp('skin', 1))
    return c.render()


def penggaris():
    c = C()
    c.poly([(1, 13), (12, 2), (14, 4), (3, 15)], 'metal', shade='edge')
    for k in range(3, 12, 2):
        c.dot(k, 14 - k, ramp('metal', 0))
    return c.render()


def sapu():
    c = C()
    c.line([(12, 1), (6, 9)], 'wood', width=1)
    c.poly([(6, 8), (8, 10), (4, 15), (1, 13)], 'khaki', shade='edge')
    c.dots([(3, 13), (4, 12), (5, 11)], ramp('khaki', 1))
    return c.render()


def pipa():
    c = C()
    c.line([(2, 14), (13, 3)], 'metal', width=2)
    c.rect(11, 1, 4, 3, 'rust', shade='edge')
    c.dots([(5, 11), (8, 8)], ramp('rust', 2))
    return c.render()


def golok():
    c = C()
    c.poly([(5, 10), (13, 1), (15, 2), (14, 5), (7, 12)], 'metal', shade='edge')
    c.line([(1, 15), (5, 11)], 'wood', width=2)
    c.dots([(14, 2)], W)
    return c.render()


def celurit():
    c = C()
    c.line([(1, 15), (5, 11)], 'wood', width=2)
    c.line([(5, 11), (8, 6), (8, 3), (6, 1), (3, 2)], 'metal', width=1)
    c.line([(6, 10), (9, 6), (9, 3)], 'metal', width=1, shade='light')
    return c.render()


def bat_paku():
    c = C()
    c.line([(2, 14), (12, 4)], 'wood', width=2)
    c.ellipse(12, 4, 3, 3, 'wood', shade='sphere')
    c.dots([(14, 1), (15, 4), (11, 0), (9, 3), (14, 7)], ramp('metal', 3))
    return c.render()


def linggis():
    c = C()
    c.line([(2, 14), (13, 3)], 'red', width=1)
    c.dots([(13, 3), (14, 4), (14, 5), (12, 2)], ramp('red', 2))
    c.dots([(1, 15), (2, 13)], ramp('red', 1))
    return c.render()


def pedang_tulang():
    c = C()
    c.poly([(5, 9), (13, 1), (15, 3), (7, 11)], 'bone', shade='edge')
    c.rect(3, 9, 5, 2, 'black', shade='flat')
    c.line([(1, 15), (4, 12)], 'black', width=2)
    c.dots([(8, 7), (10, 5), (12, 3)], ramp('bone', 1))
    return c.render()


def trisula():
    c = C()
    c.line([(1, 15), (10, 6)], 'black', width=1)
    c.stamp(8, 0, [
        "....m.m",
        ".....mm",
        "..mmmm.",
        "...mm..",
        "m.m.m..",
        ".mm....",
        "..m....",
    ], {'m': 'lava'}, shade='flat')
    return c.render()


def gergaji():
    c = C()
    c.poly([(4, 10), (13, 1), (15, 4), (7, 12)], 'metal', shade='edge')
    for k in range(0, 8, 2):
        c.dot(14 - k + 1, 3 + k, ramp('metal', 0))
    c.rrect(1, 10, 5, 5, 'red', shade='edge')
    c.dots([(2, 9), (8, 8)], ramp('red', 2))
    return c.render()


def scalpel():
    c = C()
    c.line([(2, 14), (8, 8)], 'teal', width=2)
    c.poly([(8, 8), (14, 1), (15, 2), (10, 9)], 'metal', shade='edge')
    c.dot(14, 2, W)
    return c.render()


def tongkat_api():
    c = C()
    c.line([(2, 15), (10, 7)], 'wood', width=2)
    c.ellipse(11.5, 5, 3, 3, 'purple', shade='sphere')
    c.poly([(10, 3), (12, 0), (14, 3), (13, 5)], 'fire', shade='flat')
    return c.render()


def kapak():
    c = C()
    c.line([(2, 15), (11, 6)], 'wood', width=2)
    c.poly([(8, 2), (14, 3), (15, 9), (11, 8)], 'metal', shade='edge')
    return c.render()


# ---------------------------------------------------------------- armor
def _shirt(mat, collar=None, extra=None):
    c = C()
    c.poly([(4, 2), (12, 2), (15, 6), (13, 8), (12, 7), (12, 14), (4, 14), (4, 7), (3, 8), (1, 6)], mat, shade='edge')
    if collar:
        c.dots([(6, 2), (7, 3), (8, 4), (9, 3), (10, 2)], ramp(collar, 1))
    if extra:
        extra(c)
    return c.render()


def seragam():
    return _shirt('white', 'white', lambda c: (c.dots([(8, 4), (8, 5), (8, 6)], ramp('grey', 2)), c.dot(10, 6, ramp('gold', 2))))


def jaket():
    return _shirt('black', 'black', lambda c: c.dots([(8, y) for y in range(4, 14)], ramp('metal', 2)))


def rompi():
    return _shirt('navy', None, lambda c: (c.rect(5, 6, 6, 3, 'yellow', shade='flat'), c.dots([(6, 7), (8, 7), (9, 7)], ramp('navy', 1))))


def zirah_tulang():
    c = C()
    c.poly([(4, 2), (12, 2), (15, 6), (13, 8), (12, 7), (12, 14), (4, 14), (4, 7), (3, 8), (1, 6)], 'black', shade='edge')
    for y in (5, 8, 11):
        c.rect(5, y, 6, 1, 'bone', shade='light')
    c.rect(7, 3, 2, 10, 'bone', shade='flat')
    return c.render()


def jubah():
    c = C()
    c.poly([(6, 1), (10, 1), (14, 15), (2, 15)], 'purple', shade='edge')
    c.poly([(7, 1), (9, 1), (9, 15), (7, 15)], 'black', shade='flat')
    c.dots([(8, 4), (8, 8)], ramp('gold', 3))
    return c.render()


def hazmat():
    return _shirt('yellow', None, lambda c: (c.rect(6, 4, 4, 3, 'glass', shade='flat'), c.dots([(7, 9), (8, 9), (9, 9), (8, 10)], ramp('black', 1))))


# ---------------------------------------------------------------- accessories
def kalung():
    c = C()
    c.line([(3, 2), (5, 7), (8, 9), (11, 7), (13, 2)], 'gold', width=1)
    c.poly([(8, 9), (11, 12), (8, 15), (5, 12)], 'red', shade='edge')
    c.dot(7, 11, W)
    return c.render()


def jam():
    c = C()
    c.rect(6, 1, 4, 14, 'black', shade='edge')
    c.ellipse(8, 8, 4, 4, 'metal', shade='sphere')
    c.ellipse(8, 8, 2.6, 2.6, 'white', shade='flat')
    c.dots([(8, 7), (8, 8), (9, 8)], ramp('black', 1))
    return c.render()


def kacamata():
    c = C()
    c.ellipse(4.5, 9, 3.2, 3, 'glass', shade='sphere')
    c.ellipse(11.5, 9, 3.2, 3, 'glass', shade='sphere')
    c.rect(7, 8, 2, 1, 'black', shade='flat')
    c.dots([(1, 7), (0, 6), (15, 7)], ramp('black', 2))
    return c.render()


def masker():
    c = C()
    c.rrect(3, 5, 10, 7, 'white', shade='edge')
    c.line([(1, 4), (3, 6)], 'white', width=1); c.line([(15, 4), (13, 6)], 'white', width=1)
    for y in (7, 9):
        c.dots([(x, y) for x in range(4, 12)], ramp('white', 1))
    return c.render()


def cincin():
    c = C()
    c.ellipse(8, 10.5, 5, 4, 'gold', shade='sphere')
    inner = [(x, y) for y in range(16) for x in range(16)
             if ((x + 0.5 - 8) / 3.0) ** 2 + ((y + 0.5 - 11) / 2.0) ** 2 <= 1]
    c.erase_px(inner)
    c.ellipse(8, 5.5, 2.6, 2.6, 'red', shade='sphere')
    c.dot(7, 5, '#ffffff')
    return c.render()


def sepatu():
    c = C()
    c.poly([(3, 4), (8, 4), (9, 9), (14, 11), (14, 14), (2, 14)], 'red', shade='edge')
    c.rect(2, 13, 13, 2, 'white', shade='flat')
    c.dots([(5, 7), (6, 8), (5, 9)], ramp('white', 2))
    return c.render()


def topi_baja():
    c = C()
    c.ellipse(8, 9, 7, 6, 'olive', shade='sphere')
    c.erase_rect(0, 10, 16, 6)
    c.rect(0, 10, 16, 2, 'olive', shade='edge')
    return c.render()


ITEMS = {
    # consumables
    'perban': perban, 'obat_merah': obat_merah, 'bidai': bidai, 'penawar': penawar, 'roti': roti,
    'air': air, 'kopi': kopi, 'jamu': jamu, 'daging': daging, 'nasi': nasi, 'batu': batu,
    'molotov': molotov, 'garam': garam, 'air_suci': air_suci, 'obat_cacing': obat_cacing,
    'obat_mata': obat_mata, 'permen': permen, 'jimat_kertas': jimat, 'dadu_emas': dadu_emas,
    'kunci': kunci, 'pisau_operasi': pisau_bedah_item, 'bom_asap': bom_asap,
    # materials
    'kain': kain, 'kayu': kayu, 'besi': besi, 'tali': tali, 'paku': paku, 'botol': botol,
    'minyak': minyak, 'herbal': herbal, 'tanduk': tanduk, 'batu_jiwa': batu_jiwa,
    'daging_tumor': daging_tumor, 'taring': taring,
    # money
    'koin': koin, 'uang': uang, 'kantong': kantong, 'emas': emas,
    # weapons
    'w_tangan': tangan, 'w_penggaris': penggaris, 'w_sapu': sapu, 'w_pipa': pipa, 'w_golok': golok,
    'w_celurit': celurit, 'w_bat': bat_paku, 'w_linggis': linggis, 'w_pedang_tulang': pedang_tulang,
    'w_trisula': trisula, 'w_gergaji': gergaji, 'w_scalpel': scalpel, 'w_tongkat': tongkat_api,
    'w_kapak': kapak,
    # armor
    'a_seragam': seragam, 'a_jaket': jaket, 'a_rompi': rompi, 'a_zirah_tulang': zirah_tulang,
    'a_jubah': jubah, 'a_hazmat': hazmat, 'a_helm': topi_baja,
    # accessories
    'x_kalung': kalung, 'x_jam': jam, 'x_kacamata': kacamata, 'x_masker': masker, 'x_cincin': cincin,
    'x_sepatu': sepatu,
}
