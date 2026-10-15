"""List English-looking literals (outside Indonesian branches) that have no entry in Loc.ID_STRINGS."""
import re, os, importlib.util
spec = importlib.util.spec_from_file_location('a', os.path.join(os.path.dirname(__file__), 'i18n_audit.py'))
a = importlib.util.module_from_spec(spec); spec.loader.exec_module(a)
ID = a.load_dict('ID_STRINGS')
SKIP = {'loc.gd', 'theme_builder.gd', 'board_gen.gd', 'sfx.gd', 'transition.gd', 'guide_book.gd'}
for dp, dn, fn in os.walk(a.ROOT):
    for f in sorted(fn):
        if not f.endswith('.gd') or f in SKIP:
            continue
        rel = os.path.relpath(os.path.join(dp, f), a.ROOT)
        id_block = None
        for no, line in enumerate(open(os.path.join(dp, f), encoding='utf-8'), 1):
            st = line.strip()
            if not st or st.startswith('#'):
                continue
            indent = len(line) - len(line.lstrip('\t'))
            if id_block is not None and indent <= id_block and not st.startswith(('"', '+', ')', ']', '}')):
                id_block = None
            if re.search(r'if (Loc\.lang == ("id"|Loc\.LANG_ID)|is_id)\s*:', line):
                id_block = indent
                continue
            if id_block is not None or 'Loc.lang' in line or 'QUIZ' in line or line.startswith('\t["'):
                continue
            for raw in a.STR_RE.findall(line):
                s = a.gd_unescape(raw)
                if s in ID or s.startswith(('res://', 'user://', '#', '[color', '[img', '[cell', '[table')):
                    continue
                if '/' in s and s.endswith('.png'):
                    continue
                if re.fullmatch(r'[a-z_0-9 %:.]+', s) or re.fullmatch(r'[A-Z][a-zA-Z]+(Label|Button|Panel\w*|Dark|Red|Clear)', s):
                    continue
                if len(re.findall(r'[A-Za-z]{2,}', s)) >= 1 and re.search(r'[a-z]{2,}', s):
                    print('%s:%d  %s' % (rel, no, s.replace(chr(10), '\n')))
