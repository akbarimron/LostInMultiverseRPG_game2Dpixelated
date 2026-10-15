"""List every multi-word string literal that is not wrapped in Loc.tr/Loc.t and not inside an Indonesian branch."""
import re, os, sys
sys.path.insert(0, os.path.dirname(__file__))
import importlib.util
spec = importlib.util.spec_from_file_location('a', os.path.join(os.path.dirname(__file__), 'i18n_audit.py'))
a = importlib.util.module_from_spec(spec); spec.loader.exec_module(a)
ROOT = a.ROOT
SKIP_FILES = {'loc.gd', 'db.gd', 'theme_builder.gd', 'board_gen.gd', 'sfx.gd', 'transition.gd'}
IGNORE = re.compile(r'^(res://|user://|#|\[color=#[0-9a-f]+\]%s\[/color\]$|%[sd]$)')
for dp, dn, fn in os.walk(ROOT):
    for f in sorted(fn):
        if not f.endswith('.gd') or f in SKIP_FILES:
            continue
        path = os.path.join(dp, f)
        rel = os.path.relpath(path, ROOT)
        id_block = None
        for no, line in enumerate(open(path, encoding='utf-8'), 1):
            st = line.strip()
            if not st or st.startswith('#'):
                continue
            indent = len(line) - len(line.lstrip('\t'))
            if id_block is not None and indent <= id_block and not st.startswith(('"', '+', ')', ']', '}')):
                id_block = None
            if re.search(r'if (Loc\.lang == ("id"|Loc\.LANG_ID)|is_id)\s*:', line):
                id_block = indent
                continue
            if id_block is not None or 'Loc.lang ==' in line or ' if is_id else ' in line:
                continue
            wrapped = set(a.gd_unescape(m.group(2)) for m in a.WRAP_RE.finditer(line))
            for raw in a.STR_RE.findall(line):
                s = a.gd_unescape(raw)
                if s in wrapped or IGNORE.match(s):
                    continue
                letters = re.findall(r'[A-Za-z]{2,}', s)
                if len(letters) >= 2 or (len(letters) == 1 and re.match(r'^[A-Z][a-z]+[!.:]?$', s.strip())):
                    if re.fullmatch(r'[a-z_0-9 ]+', s):     # ids / keys
                        continue
                    print('%s:%d  %s' % (rel, no, s.replace('\n', '\n')))
