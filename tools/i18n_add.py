"""Insert missing EN->ID pairs into Loc.ID_STRINGS.
Usage: python tools/i18n_add.py pairs.json
"""
import json, sys, os

LOC = os.path.join(os.path.dirname(__file__), '..', 'lostin-multiverserpg', 'scripts', 'core', 'loc.gd')
BS = chr(92)   # backslash
QT = chr(34)   # double quote


def gd_str(s):
    s = s.replace(BS, BS + BS).replace(QT, BS + QT).replace(chr(10), BS + 'n')
    return QT + s + QT


def main(path):
    pairs = json.load(open(path, encoding='utf-8'))
    src = open(LOC, encoding='utf-8').read()
    start = src.index('const ID_STRINGS := {')
    end = src.index('\n}', start)
    block = src[start:end]
    lines = []
    for en, idv in pairs.items():
        if gd_str(en) + ':' in block:
            continue
        lines.append('\t%s: %s,' % (gd_str(en), gd_str(idv)))
    if lines:
        src = src[:end] + '\n\t# --- added by tools/i18n_add.py\n' + '\n'.join(lines) + src[end:]
        open(LOC, 'w', encoding='utf-8').write(src)
    print('added', len(lines), 'of', len(pairs))


if __name__ == '__main__':
    main(sys.argv[1])
