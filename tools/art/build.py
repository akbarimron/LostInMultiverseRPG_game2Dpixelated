"""Export every generated asset into the Godot project (res://assets/gen/...)."""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from PIL import Image
import chars, items, ui, bg, font
from pxlib import shift_rows, sheet

ROOT = os.path.join(os.path.dirname(__file__), '..', '..', 'lostin-multiverserpg', 'assets', 'gen')
ROOT = os.path.abspath(ROOT)


def out(*p):
    path = os.path.join(ROOT, *p)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    return path


def breathe(img):
    h = img.size[1]
    return shift_rows(img, 0, int(h * 0.72), 1)


def strip(frames):
    w, h = frames[0].size
    s = Image.new('RGBA', (w * len(frames), h), (0, 0, 0, 0))
    for i, f in enumerate(frames):
        s.alpha_composite(f, (i * w, 0))
    return s


def main():
    n = 0
    # player
    for k, f in chars.PLAYER.items():
        im = f()
        im.save(out('chars', f'player_{k}.png')); n += 1
        if k in ('idle', 'front'):
            breathe(im).save(out('chars', f'player_{k}2.png')); n += 1
    # enemies (+ breathing frame)
    for k, f in chars.ENEMIES.items():
        im = f()
        im.save(out('enemies', f'{k}.png'))
        breathe(im).save(out('enemies', f'{k}_2.png')); n += 2
    for k, f in items.ITEMS.items():
        f().save(out('items', f'{k}.png')); n += 1
    for k, f in ui.STATUS.items():
        f().save(out('status', f'{k}.png')); n += 1
    for k, f in ui.STATICONS.items():
        f().save(out('icons', f'{k}.png')); n += 1
    for d in range(1, 7):
        ui.die(d).save(out('dice', f'die_{d}.png')); n += 1
    ui.die_blur().save(out('dice', 'die_blur.png'))
    for s in (1, 2, 3):
        for v in range(4):
            ui.plate(s, v).save(out('tiles', f'plate_s{s}_{v}.png')); n += 1
        ui.ground(s).save(out('tiles', f'ground_s{s}.png'))
        for pk, pf in ui.PROPS[s].items():
            pf().save(out('props', f's{s}_{pk}.png')); n += 1
    ui.rim().save(out('tiles', 'rim.png'))
    ui.fog_tile().save(out('tiles', 'fog.png'))
    for k, f in ui.TILE_ICONS.items():
        f().save(out('tiles', f'icon_{k}.png')); n += 1
    ui.panel().save(out('ui', 'panel.png'))
    ui.panel(fill='#1f0c12', rim='#6a2232', hi='#a83c4a', rivet='#e8c42a').save(out('ui', 'panel_red.png'))
    ui.panel(fill='#0e0b14', rim='#2a2236', hi='#3a3048', rivet='#5a4a6a').save(out('ui', 'panel_dark.png'))
    for st in ('normal', 'hover', 'pressed', 'disabled', 'focus'):
        ui.button(st).save(out('ui', f'btn_{st}.png'))
    for st in ('normal', 'hover', 'equip'):
        ui.slot(st).save(out('ui', f'slot_{st}.png'))
    ui.bar_frame().save(out('ui', 'bar_frame.png'))
    ui.arrow_down().save(out('ui', 'arrow_down.png'))
    ui.arrow_right().save(out('ui', 'arrow_right.png'))
    ui.cursor_hand().save(out('ui', 'cursor.png'))
    ui.shadow_blob().save(out('ui', 'shadow.png'))
    ui.shadow_blob(36, 8).save(out('ui', 'shadow_big.png'))
    for k, (f, cnt) in ui.VFX.items():
        strip([f(i) for i in range(cnt)]).save(out('vfx', f'{k}.png')); n += 1
    for k, f in bg.BGS.items():
        f().save(out('bg', f'{k}.png')); n += 1
    font.build(os.path.join(ROOT, 'fonts'), 'pixel')
    print('exported', n, 'assets to', ROOT)


if __name__ == '__main__':
    main()
