import sys
sys.path.insert(0, '.')
from pxlib import sheet
import chars
imgs = [f() for f in chars.PLAYER.values()]
imgs += [f() for k, f in chars.ENEMIES.items()]
s = sheet(imgs, 7, scale=4)
s.save('_preview/chars.png')
print(s.size)
