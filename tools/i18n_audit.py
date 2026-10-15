"""Audit the Godot project for mixed-language text.

Reports:
  A) Indonesian words inside source string literals (source text must be English)
  B) Strings given to Loc.tr()/Loc.t() that have no Indonesian translation
  C) DB data strings (names, descs, msgs...) without Indonesian translation
  D) Player-facing literals that are NOT wrapped in Loc.tr()/Loc.t()
Usage: python tools/i18n_audit.py [--keys-out file]
"""
import re, os, sys, json

ROOT = os.path.join(os.path.dirname(__file__), '..', 'lostin-multiverserpg', 'scripts')
LOC = os.path.join(ROOT, 'core', 'loc.gd')

STR_RE = re.compile(r'"((?:[^"\\]|\\.)*)"')
ID_WORDS = set("""kamu kau aku dan yang tidak di ke dari dengan untuk lapar langkah koin pilih lanjut tutup tas peta
pakai buang racik kondisi hilang sembuh berhasil memasang lempar dadu buta selesai beli jual klik dipakai harga senjata
zirah aksesori barang kosong semua konsumsi perlengkapan bahan fobia nama main keluar cara ulangi siklus musuh serang
bertahan kabur kembali giliran menang bagian gagal terkena memakai belum sudah akan bisa ini itu ada atau juga lagi
saat jika kalau untuk karena tapi namun mati hidup darah luka obat racun patah tulang tubuh kepala badan lengan kaki
peti kunci jebakan pedagang istirahat altar misteri harta kotak papan bertarung menyerang lawan tumbang kalah
menghindar meleset kritis pingsan takut kegilaan kutukan benjolan terbakar halusinasi berdarah infeksi
kenyang lelah jalan mundur masuk pergi berdoa berjudi tidur rawat masak dapat mendapatkan menemukan""".split())
UI_CALLS = ('UI.label(', 'UI.button(', 'UI.rich(', '.text =', 'tooltip_text', 'emit_signal("message"', 'log_msg(',
            'popup(', 'dialog.ask(', 'dialog.info(', '.ask(', '.info(', 'banner(', 'push_log(', 'show_menu(', '_msg(',
            'game_over(', 'append(', 'set_roll_enabled(', 'draw_string(', '"text":', '"tip":', 'death_reason')
WRAP_RE = re.compile(r'(Loc\.tr|Loc\.t|\btr)\(\s*"((?:[^"\\]|\\.)*)"')


def gd_unescape(s):
    def rep(m):
        c = m.group(1)
        if c.startswith('u'):
            return chr(int(c[1:], 16))
        return {'n': chr(10), 't': chr(9)}.get(c, c)
    return re.sub(r'\\(u[0-9a-fA-F]{4}|.)', rep, s)


def load_dict(name):
    src = open(LOC, encoding='utf-8').read()
    m = re.search(r'const %s := \{(.*?)\n\}' % name, src, re.S)
    keys = {}
    if not m:
        return keys
    for line in m.group(1).split('\n'):
        ms = STR_RE.findall(line)
        if len(ms) >= 2 and re.match(r'\s*"', line):
            keys[gd_unescape(ms[0])] = gd_unescape(ms[1])
    return keys


def is_textual(s):
    words = re.findall(r'[A-Za-z]{2,}', s)
    return len(words) >= 1 and not s.startswith(('res://', 'user://', '#')) and not re.fullmatch(r'[a-z_0-9]+', s)


def main():
    ID = load_dict('ID_STRINGS')
    files = []
    for dp, dn, fn in os.walk(ROOT):
        for f in fn:
            if f.endswith('.gd') and f != 'loc.gd':
                files.append(os.path.join(dp, f))
    A, B, D = [], [], []
    for path in sorted(files):
        rel = os.path.relpath(path, ROOT)
        id_block = None   # indentation of an `if Loc.lang == "id":` block we are inside
        for no, line in enumerate(open(path, encoding='utf-8'), 1):
            code = line.split('#')[0] if not line.strip().startswith('##') else ''
            if not code.strip():
                continue
            indent = len(line) - len(line.lstrip('	'))
            if id_block is not None and indent <= id_block and not code.strip().startswith(('"', '+', ')', ']', '}')):
                id_block = None
            if re.search(r'if Loc\.lang == ("id"|LANG_ID|Loc\.LANG_ID)\s*:', code):
                id_block = indent
                continue
            in_id = id_block is not None or re.search(r'Loc\.lang\s*==', code) is not None
            wrapped = set(gd_unescape(m.group(2)) for m in WRAP_RE.finditer(code))
            for w in wrapped:
                if w not in ID and is_textual(w):
                    B.append((rel, no, w))
            for raw in STR_RE.findall(code):
                s = gd_unescape(raw)
                words = set(w.lower() for w in re.findall(r'[A-Za-z]+', s))
                if words & ID_WORDS and is_textual(s) and not in_id:
                    A.append((rel, no, s))
                if in_id:
                    continue
                if s in wrapped or not is_textual(s):
                    continue
                if ' ' in s.strip() or re.search(r'[A-Z][a-z]', s):
                    if any(c in code for c in UI_CALLS) and 'Loc.' not in code.split('"')[0][-12:]:
                        D.append((rel, no, s))
    # C) DB data strings
    C = []
    db = open(os.path.join(ROOT, 'core', 'db.gd'), encoding='utf-8').read()
    for key in ('name', 'sub', 'intro', 'desc', 'msg', 'rest_name', 'shrine_name', 'cause', 'cure'):
        for m in re.finditer(r'"%s":\s*"((?:[^"\\]|\\.)*)"' % key, db):
            s = gd_unescape(m.group(1))
            if s not in ID and is_textual(s):
                C.append((key, s))
    for m in re.finditer(r'^\t"(\w+)": "((?:[^"\\]|\\.)*)",$', db, re.M):   # PART_EFFECT style
        s = gd_unescape(m.group(2))
        if s not in ID and ' ' in s:
            C.append(('const', s))

    def show(title, rows, fmt):
        print('=' * 8, title, len(rows))
        for r in rows[:400]:
            print('  ' + fmt(r))
    show('A) Indonesian text in source', A, lambda r: '%s:%d  %s' % r)
    show('B) Loc.tr() keys missing an Indonesian translation', B, lambda r: '%s:%d  %s' % r)
    show('C) DB strings missing an Indonesian translation', C, lambda r: '[%s] %s' % r)
    show('D) UI literals NOT wrapped in Loc.tr (review)', D, lambda r: '%s:%d  %s' % r)
    if '--keys-out' in sys.argv:
        out = sys.argv[sys.argv.index('--keys-out') + 1]
        miss = sorted(set([r[2] for r in B] + [r[1] for r in C]))
        json.dump(miss, open(out, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
        print('missing keys written:', len(miss), '->', out)


if __name__ == '__main__':
    main()
