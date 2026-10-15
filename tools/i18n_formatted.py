"""Find formatted strings  "text %s" % x  that are NOT wrapped in Loc.t()  (auto-translate can't catch them)."""
import re, os

ROOT = os.path.join(os.path.dirname(__file__), '..', 'lostin-multiverserpg', 'scripts')
BS = chr(92)
pat = re.compile('(Loc[.]t[(]' + BS + 's*)?"((?:[^"' + BS + BS + ']|' + BS + BS + '.)*)"' + BS + 's*%')

for dp, dn, fn in os.walk(ROOT):
    for f in sorted(fn):
        if not f.endswith('.gd') or f in ('loc.gd', 'guide_book.gd'):
            continue
        p = os.path.join(dp, f)
        for no, line in enumerate(open(p, encoding='utf-8'), 1):
            if line.strip().startswith('#') or 'Loc.lang' in line:
                continue
            for m in pat.finditer(line):
                if m.group(1):
                    continue
                s = m.group(2)
                if 'res://' in s or s.endswith('.png') or s.startswith(('[cell]', '[img')):
                    continue
                clean = re.sub(r'\[/?color[^\]]*\]', '', s)
                if re.findall(r'[A-Za-z]{3,}', clean):
                    print('%s:%d  %s' % (os.path.relpath(p, ROOT), no, s))
