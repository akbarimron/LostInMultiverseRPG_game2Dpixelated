"""Procedural 8-bit-ish SFX + dark ambient loops -> res://assets/gen/audio/*.wav"""
import wave, struct, math, random, os

SR = 22050
OUT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'lostin-multiverserpg', 'assets', 'gen', 'audio'))
os.makedirs(OUT, exist_ok=True)


def write(name, samples):
    path = os.path.join(OUT, name + '.wav')
    with wave.open(path, 'w') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        data = b''.join(struct.pack('<h', int(max(-1, min(1, s)) * 30000)) for s in samples)
        w.writeframes(data)


def env(i, n, a=0.005, r=0.6):
    t = i / SR
    T = n / SR
    if t < a:
        return t / a
    return max(0.0, 1 - (t - a) / max(1e-4, (T - a))) ** (1 / max(0.1, r))


def sq(f, t, duty=0.5):
    return 1.0 if (f * t) % 1.0 < duty else -1.0


def tri(f, t):
    p = (f * t) % 1.0
    return 4 * abs(p - 0.5) - 1


def tone(freqs, dur, wave_fn=sq, vol=0.5, slide=0.0, duty=0.5, rel=0.7):
    n = int(SR * dur)
    out = []
    for i in range(n):
        t = i / SR
        k = min(len(freqs) - 1, int(i / n * len(freqs)))
        f = freqs[k] * (1 + slide * t)
        s = wave_fn(f, t, duty) if wave_fn is sq else wave_fn(f, t)
        out.append(s * vol * env(i, n, r=rel))
    return out


def noise(dur, vol=0.5, lp=0.5, rel=0.5, seed=1):
    rnd = random.Random(seed)
    n = int(SR * dur)
    out, prev = [], 0
    for i in range(n):
        v = rnd.uniform(-1, 1)
        prev = prev + (v - prev) * lp
        out.append(prev * vol * env(i, n, r=rel))
    return out


def mix(*tracks):
    n = max(len(t) for t in tracks)
    return [sum(t[i] if i < len(t) else 0 for t in tracks) for i in range(n)]


def cat(*tracks):
    out = []
    for t in tracks:
        out += t
    return out


def silence(d):
    return [0.0] * int(SR * d)


def build():
    write('select', tone([660, 990], 0.08, vol=0.3))
    write('move', tone([520], 0.04, vol=0.18))
    write('cancel', tone([440, 330], 0.09, vol=0.25))
    write('error', tone([180, 140], 0.18, vol=0.3, duty=0.25))
    write('step', mix(noise(0.05, 0.35, 0.3, seed=3), tone([140], 0.05, tri, vol=0.4)))
    clicks = []
    rnd = random.Random(9)
    for k in range(9):
        clicks += mix(noise(0.025, 0.5, 0.6, seed=k), tone([rnd.randint(700, 1300)], 0.02, vol=0.15))
        clicks += silence(0.02 + k * 0.006)
    write('dice', clicks)
    write('dice_land', mix(noise(0.08, 0.5, 0.4, seed=4), tone([880, 1320], 0.18, vol=0.25)))
    write('hit', mix(noise(0.12, 0.8, 0.5, seed=5), tone([180, 90], 0.12, vol=0.5, duty=0.3)))
    write('hit_heavy', mix(noise(0.22, 0.9, 0.35, seed=6), tone([120, 60, 40], 0.25, vol=0.6, duty=0.3)))
    write('crit', cat(tone([1200], 0.03, vol=0.3), mix(noise(0.18, 0.9, 0.6, seed=7), tone([300, 150, 75], 0.2, vol=0.5))))
    write('miss', noise(0.15, 0.3, 0.1, rel=0.3, seed=8))
    write('parry', mix(tone([1760, 2200], 0.25, tri, vol=0.4, rel=0.4), tone([1320], 0.25, vol=0.15, duty=0.12), noise(0.05, 0.4, 0.9, seed=2)))
    write('guard', mix(tone([660, 440], 0.15, tri, vol=0.4), noise(0.06, 0.4, 0.7, seed=12)))
    write('heal', cat(tone([523], 0.07, tri, vol=0.35), tone([659], 0.07, tri, vol=0.35), tone([784, 1046], 0.16, tri, vol=0.35)))
    write('coin', cat(tone([988], 0.05, vol=0.25, duty=0.25), tone([1319], 0.14, vol=0.25, duty=0.25)))
    write('buy', cat(tone([784], 0.05, vol=0.25), tone([988], 0.05, vol=0.25), tone([1319], 0.1, vol=0.25)))
    write('open', cat(noise(0.06, 0.4, 0.3, seed=13), tone([392, 523, 659, 784], 0.3, vol=0.25, duty=0.25)))
    write('levelup', cat(*[tone([f], 0.08, vol=0.3, duty=0.25) for f in (523, 659, 784, 1046)], tone([1046, 1318], 0.3, tri, vol=0.35)))
    write('status_bad', mix(tone([300, 200, 150], 0.3, vol=0.25, duty=0.2, slide=-0.6), noise(0.3, 0.15, 0.2, seed=14)))
    write('fire', noise(0.5, 0.6, 0.25, rel=0.4, seed=15))
    write('magic', mix(tone([440, 554, 659, 880], 0.4, tri, vol=0.3), tone([220], 0.4, vol=0.1, duty=0.1)))
    write('portal', mix(tone([110], 1.2, tri, vol=0.4, slide=1.5), noise(1.2, 0.25, 0.05, rel=1.0, seed=16)))
    write('encounter', cat(tone([196], 0.1, vol=0.4, duty=0.3), tone([185], 0.1, vol=0.4, duty=0.3), tone([98, 92], 0.45, vol=0.45, duty=0.3)))
    write('boss', cat(tone([65], 0.4, vol=0.6, duty=0.3), tone([62], 0.4, vol=0.6, duty=0.3), tone([55], 0.8, vol=0.6, duty=0.3)))
    write('death', tone([392, 330, 262, 196, 131], 1.0, tri, vol=0.4, rel=1.5))
    write('steal', cat(tone([1200, 600], 0.08, vol=0.2), tone([1200, 600], 0.08, vol=0.2)))
    write('trap', mix(noise(0.25, 0.9, 0.7, seed=17), tone([900, 400], 0.1, vol=0.3, duty=0.1)))
    write('growl', mix(noise(0.6, 0.5, 0.06, rel=0.5, seed=18), tone([70, 60, 55], 0.6, vol=0.35, duty=0.4)))
    write('whisper', noise(0.7, 0.25, 0.8, rel=0.4, seed=19))
    write('victory', cat(*[tone([f], 0.1, vol=0.3, duty=0.25) for f in (392, 523, 659)], tone([784], 0.12, vol=0.3, duty=0.25), silence(0.05), tone([659, 784], 0.4, tri, vol=0.35)))


def ambient(name, root, scale, seed, bright=1.0, dur=24.0):
    """slow dark drone with sparse bell notes; loops seamlessly (fade edges)"""
    rnd = random.Random(seed)
    n = int(SR * dur)
    out = [0.0] * n
    # drone
    for i in range(n):
        t = i / SR
        lfo = 0.5 + 0.5 * math.sin(2 * math.pi * t / dur * 2)
        s = 0.22 * math.sin(2 * math.pi * root * t) + 0.12 * math.sin(2 * math.pi * root * 1.5 * t + lfo)
        s += 0.06 * tri(root * 2.01, t) * lfo
        out[i] = s
    # bells
    t = 0.5
    while t < dur - 2:
        f = root * 4 * scale[rnd.randrange(len(scale))] * bright
        ln = int(SR * 1.6)
        st = int(SR * t)
        for k in range(ln):
            if st + k < n:
                e = math.exp(-k / SR * 2.6)
                out[st + k] += 0.10 * e * math.sin(2 * math.pi * f * k / SR) + 0.03 * e * math.sin(2 * math.pi * f * 2.7 * k / SR)
        t += rnd.choice((1.5, 2.0, 3.0, 4.0))
    # crossfade the loop seam
    fade = int(SR * 1.0)
    for i in range(fade):
        a = i / fade
        out[i] = out[i] * a + out[n - fade + i] * (1 - a)
    out = out[:n - fade]
    write(name, [s * 0.8 for s in out])


if __name__ == '__main__':
    build()
    minor = [1, 1.189, 1.335, 1.498, 1.587]
    phryg = [1, 1.059, 1.189, 1.335, 1.498, 1.587]
    ambient('music_title', 55, minor, 1, 1.0)
    ambient('music_s1', 65.4, minor, 2, 1.0)
    ambient('music_s2', 49, phryg, 3, 0.75)
    ambient('music_s3', 58.3, [1, 1.06, 1.26, 1.41, 1.5], 4, 0.9)
    ambient('music_battle', 73.4, phryg, 5, 1.2, dur=16.0)
    print('audio written to', OUT)
