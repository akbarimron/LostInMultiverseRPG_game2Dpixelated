import os
from PIL import Image

output_dir = r"d:\Project\Programming_LostInMultiverseRPG\assets\sprites\zombie_ref_32x32"
brain_dir = r"C:\Users\akbar\.gemini\antigravity\brain\4c54dd00-946b-4386-8e72-bc71621cdcf1"
os.makedirs(output_dir, exist_ok=True)

# -------------------------------------------------------------
# PALETTE: ZOMBIE ANAK SMA (SERAGAM PUTIH - ABU-ABU)
# -------------------------------------------------------------
PALETTE_SMA = {
    '.': (0, 0, 0, 0),             # Transparent
    '#': (47, 47, 46, 255),        # Charcoal outline
    'H': (40, 42, 46, 255),        # Messy black teen hair dark
    'h': (68, 70, 76, 255),        # Hair highlight
    'G': (109, 142, 110, 255),     # Rotten green skin light
    'g': (90, 118, 91, 255),       # Rotten green skin dark
    'E': (102, 162, 208, 255),     # Cyan glowing eye
    'e': (255, 255, 255, 255),     # Eye glint white
    'T': (218, 217, 204, 255),     # White teeth / fangs
    'W': (235, 234, 226, 255),     # White SMA shirt light
    'w': (186, 184, 172, 255),     # White SMA shirt shadow
    'D': (56, 62, 74, 255),        # Gray tie (Dasi SMA)
    'R': (198, 44, 44, 255),       # Blood stain light
    'r': (142, 28, 28, 255),       # Blood stain dark
    'A': (126, 136, 150, 255),     # Gray SMA trousers light
    'a': (86, 94, 108, 255),       # Gray SMA trousers dark
    'S': (32, 34, 38, 255),        # Black school shoes
    'K': (230, 230, 230, 255),     # White sneaker trim / socks
}

# -------------------------------------------------------------
# 8-FRAME WALK CYCLE: ZOMBIE SISWA SMA (32x32)
# -------------------------------------------------------------

# Frame 1: Contact 1 (Left foot forward, Right foot back)
sma_f1 = [
    '................................', # 0
    '...............##...............', # 1  Messy teen hair
    '..........###..#Hh#..##.........', # 2
    '.........#HHH##Hhh#.#HH#........', # 3
    '........#HHHHHHHHHHHHHH#........', # 4
    '........#HHHHHHHHHHHHHHH#.......', # 5
    '........#HHHH#ggggGGGG#H#.......', # 6  Forehead under bangs
    '........#HH#gGGGGGGGG#HH#.......', # 7
    '.........##gG#eE#gGG#eE#g#......', # 8  Cyan-white glowing eyes
    '..........#gg#ee#gGG#ee#g#......', # 9
    '..........#ggg####gg###g#.......', # 10 Open mouth
    '..........#ggg#TT#gg#TTg#.......', # 11 White teeth/fangs
    '..........##ggg##gggg##g#.......', # 12 Jaw
    '...........#gWW#DD#WWg#.........', # 13 Collar (White shirt W + Gray tie D)
    '....###...#wWWW#DD#WWWw#...###..', # 14 White SMA shirt with gray tie
    '..#wWW#..#wWWWRrrRWWWW#..#wWW#..', # 15 Ripped shirt & blood splatter R, r
    '.#GGGGG##wWWRrrrrRWWWw##GGGGG#..', # 16 Outstretched green zombie arms
    '.#G#G#G#wwwwRrrrrRwwww#G#G#G#...', # 17 3-finger claws
    '..#####.##SSSSSSSSSSSS##.#####..', # 18 School belt S
    '.........#aAAAAAAAAAAa#.........', # 19 Gray SMA trousers (Abu-abu SMA)
    '.........#aAAAAAAAAAAa#.........', # 20
    '.........#aa########aa#.........', # 21 Trousers split
    '........#aAA#......#aA#.........', # 22 Left leg forward, Right leg back
    '........#aAA#......#aA#.........', # 23
    '.......#gGG#........#gg#........', # 24 Torn cuff showing rotten green shin
    '.......#gGG#........#gg#........', # 25
    '.......#SKK#........#SK#........', # 26 School shoes S with white trim K
    '........###..........##.........', # 27 Left foot flat, right heel up
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 2: Down 1 (Left knee flexes, torso & head bob down 1px) - Y+1
sma_f2 = [
    '................................', # 0
    '................................', # 1
    '...............##...............', # 2  (Everything dropped 1px)
    '..........###..#Hh#..##.........', # 3
    '.........#HHH##Hhh#.#HH#........', # 4
    '........#HHHHHHHHHHHHHH#........', # 5
    '........#HHHHHHHHHHHHHHH#.......', # 6
    '........#HHHH#ggggGGGG#H#.......', # 7
    '........#HH#gGGGGGGGG#HH#.......', # 8
    '.........##gG#eE#gGG#eE#g#......', # 9  Eyes
    '..........#gg#ee#gGG#ee#g#......', # 10
    '..........#ggg####gg###g#.......', # 11 Mouth
    '..........#ggg#TT#gg#TTg#.......', # 12
    '..........##ggg##gggg##g#.......', # 13
    '...........#gWW#DD#WWg#.........', # 14
    '....###...#wWWW#DD#WWWw#...###..', # 15 Arms dip with recoil
    '..#wWW#..#wWWWRrrRWWWW#..#wWW#..', # 16
    '.#GGGGG##wWWRrrrrRWWWw##GGGGG#..', # 17
    '.#G#G#G#wwwwRrrrrRwwww#G#G#G#...', # 18
    '..#####.##SSSSSSSSSSSS##.#####..', # 19
    '.........#aAAAAAAAAAAa#.........', # 20
    '.........#aa########aa#.........', # 21
    '........#aAA#.......##..........', # 22 Left knee absorbs recoil
    '.......#aAAA#......#aA#.........', # 23 Right heel peeling up
    '.......#gGG#.......#gg#.........', # 24
    '.......#SKK#........#SK#........', # 25
    '........###..........##.........', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 3: Passing 1 (Right leg passes center, left leg straight) - Base Y
sma_f3 = [
    '................................', # 0
    '...............##...............', # 1
    '..........###..#Hh#..##.........', # 2
    '.........#HHH##Hhh#.#HH#........', # 3
    '........#HHHHHHHHHHHHHH#........', # 4
    '........#HHHHHHHHHHHHHHH#.......', # 5
    '........#HHHH#ggggGGGG#H#.......', # 6
    '........#HH#gGGGGGGGG#HH#.......', # 7
    '.........##gG#eE#gGG#eE#g#......', # 8
    '..........#gg#ee#gGG#ee#g#......', # 9
    '..........#ggg####gg###g#.......', # 10
    '..........#ggg#TT#gg#TTg#.......', # 11
    '..........##ggg##gggg##g#.......', # 12
    '...........#gWW#DD#WWg#.........', # 13
    '....###...#wWWW#DD#WWWw#...###..', # 14 Arms centered
    '..#wWW#..#wWWWRrrRWWWW#..#wWW#..', # 15
    '.#GGGGG##wWWRrrrrRWWWw##GGGGG#..', # 16
    '.#G#G#G#wwwwRrrrrRwwww#G#G#G#...', # 17
    '..#####.##SSSSSSSSSSSS##.#####..', # 18
    '.........#aAAAAAAAAAAa#.........', # 19
    '.........#aAAAAAAAAAAa#.........', # 20
    '.........#aAAAAAAAAAAa#.........', # 21
    '........#aAA###aA#..............', # 22 Right leg passing under torso
    '........#aAA##aAA#..............', # 23
    '........#gGG##gg#...............', # 24 Right foot in air
    '........#SKK#.#..#..............', # 25 Left foot firmly planted
    '.........###....................', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 4: Up 1 (Left leg pushes up, body rises 1px, right leg reaches) - Y-1
sma_f4 = [
    '...............##...............', # 0  (Head rises 1px up!)
    '..........###..#Hh#..##.........', # 1
    '.........#HHH##Hhh#.#HH#........', # 2
    '........#HHHHHHHHHHHHHH#........', # 3
    '........#HHHHHHHHHHHHHHH#.......', # 4
    '........#HHHH#ggggGGGG#H#.......', # 5
    '........#HH#gGGGGGGGG#HH#.......', # 6
    '.........##gG#eE#gGG#eE#g#......', # 7
    '..........#gg#ee#gGG#ee#g#......', # 8
    '..........#ggg####gg###g#.......', # 9
    '..........#ggg#TT#gg#TTg#.......', # 10
    '..........##ggg##gggg##g#.......', # 11
    '...........#gWW#DD#WWg#.........', # 12
    '....###...#wWWW#DD#WWWw#...###..', # 13 Arms reach higher
    '..#wWW#..#wWWWRrrRWWWW#..#wWW#..', # 14
    '.#GGGGG##wWWRrrrrRWWWw##GGGGG#..', # 15
    '.#G#G#G#wwwwRrrrrRwwww#G#G#G#...', # 16
    '..#####.##SSSSSSSSSSSS##.#####..', # 17
    '.........#aAAAAAAAAAAa#.........', # 18
    '.........#aAAAAAAAAAAa#.........', # 19
    '.........#aa########aa#.........', # 20
    '........#aAA#......#aA#.........', # 21 Right leg extending forward
    '........#aAA#......#aAA#........', # 22
    '........#gGG#.......#gg#........', # 23
    '.........#SK#........#SK#.......', # 24 Tiptoe push
    '..........##.........#SK#.......', # 25 Right foot reaching down
    '......................##........', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 5: Contact 2 (Right foot forward, Left foot back) - Base Y
sma_f5 = [
    '................................', # 0
    '...............##...............', # 1
    '..........###..#Hh#..##.........', # 2
    '.........#HHH##Hhh#.#HH#........', # 3
    '........#HHHHHHHHHHHHHH#........', # 4
    '........#HHHHHHHHHHHHHHH#.......', # 5
    '........#HHHH#ggggGGGG#H#.......', # 6
    '........#HH#gGGGGGGGG#HH#.......', # 7
    '.........##gG#eE#gGG#eE#g#......', # 8
    '..........#gg#ee#gGG#ee#g#......', # 9
    '..........#ggg####gg###g#.......', # 10
    '..........#ggg#TT#gg#TTg#.......', # 11
    '..........##ggg##gggg##g#.......', # 12
    '...........#gWW#DD#WWg#.........', # 13
    '....###...#wWWW#DD#WWWw#...###..', # 14
    '..#wWW#..#wWWWRrrRWWWW#..#wWW#..', # 15
    '.#GGGGG##wWWRrrrrRWWWw##GGGGG#..', # 16
    '.#G#G#G#wwwwRrrrrRwwww#G#G#G#...', # 17
    '..#####.##SSSSSSSSSSSS##.#####..', # 18
    '.........#aAAAAAAAAAAa#.........', # 19
    '.........#aAAAAAAAAAAa#.........', # 20
    '.........#aa########aa#.........', # 21
    '........#aA#......#aAA#.........', # 22 Right foot forward, Left foot back
    '........#aA#......#aAA#.........', # 23
    '.......#gg#........#gGG#........', # 24
    '.......#gg#........#gGG#........', # 25
    '.......#SK#........#SKK#........', # 26 Right foot flat, left heel up
    '........##..........###.........', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 6: Down 2 (Right knee flexes, torso & head bob down 1px) - Y+1
sma_f6 = [
    '................................', # 0
    '................................', # 1
    '...............##...............', # 2  (Everything dropped 1px)
    '..........###..#Hh#..##.........', # 3
    '.........#HHH##Hhh#.#HH#........', # 4
    '........#HHHHHHHHHHHHHH#........', # 5
    '........#HHHHHHHHHHHHHHH#.......', # 6
    '........#HHHH#ggggGGGG#H#.......', # 7
    '........#HH#gGGGGGGGG#HH#.......', # 8
    '.........##gG#eE#gGG#eE#g#......', # 9  Eyes
    '..........#gg#ee#gGG#ee#g#......', # 10
    '..........#ggg####gg###g#.......', # 11 Mouth
    '..........#ggg#TT#gg#TTg#.......', # 12
    '..........##ggg##gggg##g#.......', # 13
    '...........#gWW#DD#WWg#.........', # 14
    '....###...#wWWW#DD#WWWw#...###..', # 15 Arms dip with recoil
    '..#wWW#..#wWWWRrrRWWWW#..#wWW#..', # 16
    '.#GGGGG##wWWRrrrrRWWWw##GGGGG#..', # 17
    '.#G#G#G#wwwwRrrrrRwwww#G#G#G#...', # 18
    '..#####.##SSSSSSSSSSSS##.#####..', # 19
    '.........#aAAAAAAAAAAa#.........', # 20
    '.........#aa########aa#.........', # 21
    '.........##.......#aAA#.........', # 22 Right knee absorbs recoil
    '........#aA#......#aAAA#........', # 23 Left heel peeling up
    '........#gg#......#gGG#.........', # 24
    '........#SK#......#SKK#.........', # 25
    '.........##........###..........', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 7: Passing 2 (Left leg passes center, right leg straight) - Base Y
sma_f7 = [
    '................................', # 0
    '...............##...............', # 1
    '..........###..#Hh#..##.........', # 2
    '.........#HHH##Hhh#.#HH#........', # 3
    '........#HHHHHHHHHHHHHH#........', # 4
    '........#HHHHHHHHHHHHHHH#.......', # 5
    '........#HHHH#ggggGGGG#H#.......', # 6
    '........#HH#gGGGGGGGG#HH#.......', # 7
    '.........##gG#eE#gGG#eE#g#......', # 8
    '..........#gg#ee#gGG#ee#g#......', # 9
    '..........#ggg####gg###g#.......', # 10
    '..........#ggg#TT#gg#TTg#.......', # 11
    '..........##ggg##gggg##g#.......', # 12
    '...........#gWW#DD#WWg#.........', # 13
    '....###...#wWWW#DD#WWWw#...###..', # 14
    '..#wWW#..#wWWWRrrRWWWW#..#wWW#..', # 15
    '.#GGGGG##wWWRrrrrRWWWw##GGGGG#..', # 16
    '.#G#G#G#wwwwRrrrrRwwww#G#G#G#...', # 17
    '..#####.##SSSSSSSSSSSS##.#####..', # 18
    '.........#aAAAAAAAAAAa#.........', # 19
    '.........#aAAAAAAAAAAa#.........', # 20
    '.........#aAAAAAAAAAAa#.........', # 21
    '..............#aA###aAA#........', # 22 Left leg passing under torso
    '.............#aAA##aAA#.........', # 23
    '..............#gg##gGG#.........', # 24 Left foot in air
    '.............#..##SKK#..........', # 25 Right foot firmly planted
    '..................###...........', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 8: Up 2 (Right leg pushes up, body rises 1px, left leg reaches) - Y-1
sma_f8 = [
    '...............##...............', # 0  (Head rises 1px up!)
    '..........###..#Hh#..##.........', # 1
    '.........#HHH##Hhh#.#HH#........', # 2
    '........#HHHHHHHHHHHHHH#........', # 3
    '........#HHHHHHHHHHHHHHH#.......', # 4
    '........#HHHH#ggggGGGG#H#.......', # 5
    '........#HH#gGGGGGGGG#HH#.......', # 6
    '.........##gG#eE#gGG#eE#g#......', # 7
    '..........#gg#ee#gGG#ee#g#......', # 8
    '..........#ggg####gg###g#.......', # 9
    '..........#ggg#TT#gg#TTg#.......', # 10
    '..........##ggg##gggg##g#.......', # 11
    '...........#gWW#DD#WWg#.........', # 12
    '....###...#wWWW#DD#WWWw#...###..', # 13 Arms reach higher
    '..#wWW#..#wWWWRrrRWWWW#..#wWW#..', # 14
    '.#GGGGG##wWWRrrrrRWWWw##GGGGG#..', # 15
    '.#G#G#G#wwwwRrrrrRwwww#G#G#G#...', # 16
    '..#####.##SSSSSSSSSSSS##.#####..', # 17
    '.........#aAAAAAAAAAAa#.........', # 18
    '.........#aAAAAAAAAAAa#.........', # 19
    '.........#aa########aa#.........', # 20
    '........#aA#......#aAA#.........', # 21 Left leg extending forward
    '.......#aAA#......#aAA#.........', # 22
    '.......#gg#........#gg#.........', # 23
    '.......#SK#........#SK#.........', # 24 Tiptoe push
    '.......#SK#.........##..........', # 25 Left foot reaching down
    '........##......................', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

frames_sma = [sma_f1, sma_f2, sma_f3, sma_f4, sma_f5, sma_f6, sma_f7, sma_f8]

# Validate row and column count
for i, fr in enumerate(frames_sma):
    assert len(fr) == 32, f"Frame {i+1} has {len(fr)} rows"
    for r_idx, row in enumerate(fr):
        assert len(row) == 32, f"Frame {i+1} row {r_idx} len={len(row)}: {row}"

print("Zombie SMA Student validated successfully!")

# Render 32x32 images
images_sma_32 = []
for idx, fr in enumerate(frames_sma):
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    for y in range(32):
        for x in range(32):
            char = fr[y][x]
            color = PALETTE_SMA.get(char, (0, 0, 0, 0))
            img.putpixel((x, y), color)
    frame_path = os.path.join(output_dir, f"zombie_sma_frame_{idx+1:02d}.png")
    img.save(frame_path)
    images_sma_32.append(img)

# Spritesheet (256x32)
sheet_sma_32 = Image.new("RGBA", (32 * 8, 32), (0, 0, 0, 0))
for idx, img in enumerate(images_sma_32):
    sheet_sma_32.paste(img, (idx * 32, 0))
sheet_sma_32.save(os.path.join(output_dir, "zombie_sma_walk_32x32_spritesheet.png"))

# Integer 8x Scaled versions
images_sma_256 = []
for idx, img in enumerate(images_sma_32):
    img_256 = img.resize((256, 256), Image.Resampling.NEAREST)
    img_256.save(os.path.join(output_dir, f"zombie_sma_frame_{idx+1:02d}_256px.png"))
    img_256.save(os.path.join(brain_dir, f"zombie_sma_frame_{idx+1:02d}.png"))
    images_sma_256.append(img_256)

sheet_sma_256 = sheet_sma_32.resize((256 * 8, 256), Image.Resampling.NEAREST)
sheet_sma_256.save(os.path.join(output_dir, "zombie_sma_walk_spritesheet_256px.png"))
sheet_sma_256.save(os.path.join(brain_dir, "zombie_sma_walk_spritesheet.png"))

# Animated GIFs (Native 32x32 & Scaled 256px)
ref_bg_color = (72, 68, 86, 255)

gif_sma_32_frames = []
for img in images_sma_32:
    bg = Image.new("RGBA", (32, 32), ref_bg_color)
    bg.paste(img, (0, 0), img)
    gif_sma_32_frames.append(bg)

gif_sma_32_frames[0].save(
    os.path.join(output_dir, "zombie_sma_walk_32x32.gif"),
    save_all=True,
    append_images=gif_sma_32_frames[1:],
    duration=110,
    loop=0
)

gif_sma_256_frames = []
for img in images_sma_256:
    bg = Image.new("RGBA", (256, 256), ref_bg_color)
    bg.paste(img, (0, 0), img)
    gif_sma_256_frames.append(bg)

gif_sma_256_path = os.path.join(output_dir, "zombie_sma_walk_256px.gif")
brain_gif_sma_path = os.path.join(brain_dir, "zombie_sma_walk_animated.gif")

gif_sma_256_frames[0].save(
    gif_sma_256_path,
    save_all=True,
    append_images=gif_sma_256_frames[1:],
    duration=110,
    loop=0
)
gif_sma_256_frames[0].save(
    brain_gif_sma_path,
    save_all=True,
    append_images=gif_sma_256_frames[1:],
    duration=110,
    loop=0
)

print("Zombie SMA assets created successfully!")
