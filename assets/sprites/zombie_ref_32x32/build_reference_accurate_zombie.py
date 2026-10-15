import os
from PIL import Image

output_dir = r"d:\Project\Programming_LostInMultiverseRPG\assets\sprites\zombie_ref_32x32"
brain_dir = r"C:\Users\akbar\.gemini\antigravity\brain\4c54dd00-946b-4386-8e72-bc71621cdcf1"
os.makedirs(output_dir, exist_ok=True)

# -------------------------------------------------------------
# PALETTE MATCHED 100% TO USER REFERENCE IMAGE (ROW 2 & ROW 1)
# -------------------------------------------------------------
PALETTE_ZOMBIE1 = {
    '.': (0, 0, 0, 0),             # Transparent
    '#': (47, 47, 46, 255),        # Deep charcoal outline
    'H': (59, 59, 57, 255),        # Dark spiky hair
    'P': (83, 55, 122, 255),       # Purple cap / pants light
    'p': (67, 46, 96, 255),        # Purple cap / pants dark
    'W': (218, 217, 204, 255),     # White tassel / teeth / fangs
    'w': (180, 180, 174, 255),     # White tassel shadow
    'G': (109, 142, 110, 255),     # Green skin light
    'g': (90, 118, 91, 255),       # Green skin dark
    'E': (102, 162, 208, 255),     # Glowing cyan eye
    'e': (255, 255, 255, 255),     # Eye glint white
    'V': (175, 118, 75, 255),      # Brown vest light
    'v': (143, 98, 63, 255),       # Brown vest dark
}

# -------------------------------------------------------------
# 8-FRAME WALK CYCLE: ZOMBIE 1 (PURPLE CAP, WHITE TASSEL, GREEN)
# -------------------------------------------------------------

# Frame 1: Contact 1 (Left foot forward, Right foot back) - Base Y
z1_f1 = [
    '................................', # 0
    '...................##...........', # 1
    '..............##..#HH#..........', # 2  Spiky dark hair
    '.......####..#HH##HHHH#.........', # 3
    '......#pppp##HHHHHHHHHH#........', # 4  Purple nightcap & spiky hair
    '.....#pPPpp#HHHHHHHHHHH#........', # 5
    '....#pPPPPp##HHHHHHHHHH#........', # 6
    '....W#ppPPp#ggggGGGGGGg#........', # 7  White tassel & green forehead
    '...WW#pppp#gGGGGGGGGGGg#........', # 8
    '..WWw#ppp#gG#eE#gGG#eE#g#.......', # 9  Glowing white/cyan rectangular eyes
    '..WWw##p##gg#ee#gGG#ee#g#.......', # 10
    '..Www#..#ggg####gg####gg#.......', # 11 Gaping mouth
    '...W#...#ggg#WW#gg#WW#gg#.......', # 12 White teeth/fangs jutting out
    '........#gggg##gggg##ggg#.......', # 13 Jaw
    '........##ggggGGGGgggg##........', # 14 Neck
    '...###...#vvVVVVVVVVvv#...###...', # 15 Brown torn vest
    '..#GGG#..#vVVVVVVVVVVv#..#GGG#..', # 16 Outstretched zombie arms
    '.#GGGGG##vVVVVVVVVVVVVv##GGGGG#.', # 17 3-claw hands reaching forward
    '.#G#G#G#vvvvVVVVVVVVvvvv#G#G#G#.', # 18 Separated fingers #G#G#G#
    '..#####.##vvvvvvvvvvvv##.#####..', # 19
    '.........#ppppPPPPpppp#.........', # 20 Purple pants
    '.........#ppppPPPPpppp#.........', # 21
    '.........#ppp######ppp#.........', # 22 Pants hem
    '........#gGG#......#gG#.........', # 23 Left leg forward, Right leg back
    '........#gGG#......#gG#.........', # 24
    '.......#gGGG#.......#gg#........', # 25
    '.......#gGGG#.......#gg#........', # 26 Left foot flat, right heel up
    '........####.........##.........', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 2: Down 1 (Left knee flexes, torso & head bobs down 1px) - Y+1
z1_f2 = [
    '................................', # 0
    '................................', # 1
    '...................##...........', # 2  (Everything dropped 1px)
    '..............##..#HH#..........', # 3
    '.......####..#HH##HHHH#.........', # 4
    '......#pppp##HHHHHHHHHH#........', # 5
    '.....#pPPpp#HHHHHHHHHHH#........', # 6
    '....#pPPPPp##HHHHHHHHHH#........', # 7
    '....W#ppPPp#ggggGGGGGGg#........', # 8
    '...WW#pppp#gGGGGGGGGGGg#........', # 9
    '..WWw#ppp#gG#eE#gGG#eE#g#.......', # 10 Eyes
    '..WWw##p##gg#ee#gGG#ee#g#.......', # 11
    '..Www#..#ggg####gg####gg#.......', # 12 Mouth
    '...W#...#ggg#WW#gg#WW#gg#.......', # 13
    '........#gggg##gggg##ggg#.......', # 14
    '........##ggggGGGGgggg##........', # 15
    '...###...#vvVVVVVVVVvv#...###...', # 16 Arms dip with recoil
    '..#GGG#..#vVVVVVVVVVVv#..#GGG#..', # 17
    '.#GGGGG##vVVVVVVVVVVVVv##GGGGG#.', # 18
    '.#G#G#G#vvvvVVVVVVVVvvvv#G#G#G#.', # 19
    '..#####.##vvvvvvvvvvvv##.#####..', # 20
    '.........#ppppPPPPpppp#.........', # 21
    '.........#ppp######ppp#.........', # 22
    '........#gGG#.......##..........', # 23 Left knee absorbs impact
    '.......#gGGG#......#gG#.........', # 24 Right foot lifting off floor
    '.......#gGGG#......#gg#.........', # 25
    '........####........##..........', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 3: Passing 1 (Right leg passes center, left leg straight) - Base Y
z1_f3 = [
    '................................', # 0
    '...................##...........', # 1
    '..............##..#HH#..........', # 2
    '.......####..#HH##HHHH#.........', # 3
    '......#pppp##HHHHHHHHHH#........', # 4
    '.....#pPPpp#HHHHHHHHHHH#........', # 5
    '....#pPPPPp##HHHHHHHHHH#........', # 6
    '....W#ppPPp#ggggGGGGGGg#........', # 7
    '...WW#pppp#gGGGGGGGGGGg#........', # 8
    '..WWw#ppp#gG#eE#gGG#eE#g#.......', # 9
    '..WWw##p##gg#ee#gGG#ee#g#.......', # 10
    '..Www#..#ggg####gg####gg#.......', # 11
    '...W#...#ggg#WW#gg#WW#gg#.......', # 12
    '........#gggg##gggg##ggg#.......', # 13
    '........##ggggGGGGgggg##........', # 14
    '...###...#vvVVVVVVVVvv#...###...', # 15 Arms centered
    '..#GGG#..#vVVVVVVVVVVv#..#GGG#..', # 16
    '.#GGGGG##vVVVVVVVVVVVVv##GGGGG#.', # 17
    '.#G#G#G#vvvvVVVVVVVVvvvv#G#G#G#.', # 18
    '..#####.##vvvvvvvvvvvv##.#####..', # 19
    '.........#ppppPPPPpppp#.........', # 20
    '.........#ppppPPPPpppp#.........', # 21
    '.........#ppppPPPPpppp#.........', # 22
    '........#gGG###gG#..............', # 23 Right leg passing under torso
    '........#gGG##gGG#..............', # 24
    '........#gGG##gg#...............', # 25 Right foot in air
    '........#gGG#.#..#..............', # 26
    '.........####...................', # 27 Left foot firmly planted
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 4: Up 1 (Left leg pushes up, body rises 1px, right leg reaches) - Y-1
z1_f4 = [
    '...................##...........', # 0  (Head rises 1px up!)
    '..............##..#HH#..........', # 1
    '.......####..#HH##HHHH#.........', # 2
    '......#pppp##HHHHHHHHHH#........', # 3
    '.....#pPPpp#HHHHHHHHHHH#........', # 4
    '....#pPPPPp##HHHHHHHHHH#........', # 5
    '....W#ppPPp#ggggGGGGGGg#........', # 6
    '...WW#pppp#gGGGGGGGGGGg#........', # 7
    '..WWw#ppp#gG#eE#gGG#eE#g#.......', # 8
    '..WWw##p##gg#ee#gGG#ee#g#.......', # 9
    '..Www#..#ggg####gg####gg#.......', # 10
    '...W#...#ggg#WW#gg#WW#gg#.......', # 11
    '........#gggg##gggg##ggg#.......', # 12
    '........##ggggGGGGgggg##........', # 13
    '...###...#vvVVVVVVVVvv#...###...', # 14 Arms reach higher
    '..#GGG#..#vVVVVVVVVVVv#..#GGG#..', # 15
    '.#GGGGG##vVVVVVVVVVVVVv##GGGGG#.', # 16
    '.#G#G#G#vvvvVVVVVVVVvvvv#G#G#G#.', # 17
    '..#####.##vvvvvvvvvvvv##.#####..', # 18
    '.........#ppppPPPPpppp#.........', # 19
    '.........#ppppPPPPpppp#.........', # 20
    '.........#ppp######ppp#.........', # 21
    '........#gGG#......#gG#.........', # 22 Right leg extending forward
    '........#gGG#......#gGG#........', # 23
    '.........#gg#.......#gg#........', # 24
    '..........##.........##.........', # 25 Tiptoe push
    '....................#gg#........', # 26 Right foot reaching down
    '.....................##.........', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 5: Contact 2 (Right foot forward, Left foot back) - Base Y
z1_f5 = [
    '................................', # 0
    '...................##...........', # 1
    '..............##..#HH#..........', # 2
    '.......####..#HH##HHHH#.........', # 3
    '......#pppp##HHHHHHHHHH#........', # 4
    '.....#pPPpp#HHHHHHHHHHH#........', # 5
    '....#pPPPPp##HHHHHHHHHH#........', # 6
    '....W#ppPPp#ggggGGGGGGg#........', # 7
    '...WW#pppp#gGGGGGGGGGGg#........', # 8
    '..WWw#ppp#gG#eE#gGG#eE#g#.......', # 9
    '..WWw##p##gg#ee#gGG#ee#g#.......', # 10
    '..Www#..#ggg####gg####gg#.......', # 11
    '...W#...#ggg#WW#gg#WW#gg#.......', # 12
    '........#gggg##gggg##ggg#.......', # 13
    '........##ggggGGGGgggg##........', # 14
    '...###...#vvVVVVVVVVvv#...###...', # 15
    '..#GGG#..#vVVVVVVVVVVv#..#GGG#..', # 16
    '.#GGGGG##vVVVVVVVVVVVVv##GGGGG#.', # 17
    '.#G#G#G#vvvvVVVVVVVVvvvv#G#G#G#.', # 18
    '..#####.##vvvvvvvvvvvv##.#####..', # 19
    '.........#ppppPPPPpppp#.........', # 20
    '.........#ppppPPPPpppp#.........', # 21
    '.........#ppp######ppp#.........', # 22
    '........#gG#......#gGG#.........', # 23 Right foot forward, Left foot back
    '........#gG#......#gGG#.........', # 24
    '.......#gg#.......#gGGG#........', # 25
    '.......#gg#.......#gGGG#........', # 26 Right foot flat, left heel up
    '........##.........####.........', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 6: Down 2 (Right knee flexes, torso & head bobs down 1px) - Y+1
z1_f6 = [
    '................................', # 0
    '................................', # 1
    '...................##...........', # 2  (Everything dropped 1px)
    '..............##..#HH#..........', # 3
    '.......####..#HH##HHHH#.........', # 4
    '......#pppp##HHHHHHHHHH#........', # 5
    '.....#pPPpp#HHHHHHHHHHH#........', # 6
    '....#pPPPPp##HHHHHHHHHH#........', # 7
    '....W#ppPPp#ggggGGGGGGg#........', # 8
    '...WW#pppp#gGGGGGGGGGGg#........', # 9
    '..WWw#ppp#gG#eE#gGG#eE#g#.......', # 10
    '..WWw##p##gg#ee#gGG#ee#g#.......', # 11
    '..Www#..#ggg####gg####gg#.......', # 12
    '...W#...#ggg#WW#gg#WW#gg#.......', # 13
    '........#gggg##gggg##ggg#.......', # 14
    '........##ggggGGGGgggg##........', # 15
    '...###...#vvVVVVVVVVvv#...###...', # 16 Arms dip with recoil
    '..#GGG#..#vVVVVVVVVVVv#..#GGG#..', # 17
    '.#GGGGG##vVVVVVVVVVVVVv##GGGGG#.', # 18
    '.#G#G#G#vvvvVVVVVVVVvvvv#G#G#G#.', # 19
    '..#####.##vvvvvvvvvvvv##.#####..', # 20
    '.........#ppppPPPPpppp#.........', # 21
    '.........#ppp######ppp#.........', # 22
    '.........##.......#gGG#.........', # 23 Right knee absorbs impact
    '........#gG#......#gGGG#........', # 24 Left foot lifting off floor
    '........#gg#......#gGGG#........', # 25
    '.........##........####.........', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 7: Passing 2 (Left leg passes center, right leg straight) - Base Y
z1_f7 = [
    '................................', # 0
    '...................##...........', # 1
    '..............##..#HH#..........', # 2
    '.......####..#HH##HHHH#.........', # 3
    '......#pppp##HHHHHHHHHH#........', # 4
    '.....#pPPpp#HHHHHHHHHHH#........', # 5
    '....#pPPPPp##HHHHHHHHHH#........', # 6
    '....W#ppPPp#ggggGGGGGGg#........', # 7
    '...WW#pppp#gGGGGGGGGGGg#........', # 8
    '..WWw#ppp#gG#eE#gGG#eE#g#.......', # 9
    '..WWw##p##gg#ee#gGG#ee#g#.......', # 10
    '..Www#..#ggg####gg####gg#.......', # 11
    '...W#...#ggg#WW#gg#WW#gg#.......', # 12
    '........#gggg##gggg##ggg#.......', # 13
    '........##ggggGGGGgggg##........', # 14
    '...###...#vvVVVVVVVVvv#...###...', # 15
    '..#GGG#..#vVVVVVVVVVVv#..#GGG#..', # 16
    '.#GGGGG##vVVVVVVVVVVVVv##GGGGG#.', # 17
    '.#G#G#G#vvvvVVVVVVVVvvvv#G#G#G#.', # 18
    '..#####.##vvvvvvvvvvvv##.#####..', # 19
    '.........#ppppPPPPpppp#.........', # 20
    '.........#ppppPPPPpppp#.........', # 21
    '.........#ppppPPPPpppp#.........', # 22
    '..............#gG###gGG#........', # 23 Left leg passing under torso
    '.............#gGG##gGG#.........', # 24
    '..............#gg##gGG#.........', # 25 Left foot in air
    '.............#..##gGG#..........', # 26
    '..................####..........', # 27 Right foot firmly planted
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 8: Up 2 (Right leg pushes up, body rises 1px, left leg reaches) - Y-1
z1_f8 = [
    '...................##...........', # 0  (Head rises 1px up!)
    '..............##..#HH#..........', # 1
    '.......####..#HH##HHHH#.........', # 2
    '......#pppp##HHHHHHHHHH#........', # 3
    '.....#pPPpp#HHHHHHHHHHH#........', # 4
    '....#pPPPPp##HHHHHHHHHH#........', # 5
    '....W#ppPPp#ggggGGGGGGg#........', # 6
    '...WW#pppp#gGGGGGGGGGGg#........', # 7
    '..WWw#ppp#gG#eE#gGG#eE#g#.......', # 8
    '..WWw##p##gg#ee#gGG#ee#g#.......', # 9
    '..Www#..#ggg####gg####gg#.......', # 10
    '...W#...#ggg#WW#gg#WW#gg#.......', # 11
    '........#gggg##gggg##ggg#.......', # 12
    '........##ggggGGGGgggg##........', # 13
    '...###...#vvVVVVVVVVvv#...###...', # 14 Arms reach higher
    '..#GGG#..#vVVVVVVVVVVv#..#GGG#..', # 15
    '.#GGGGG##vVVVVVVVVVVVVv##GGGGG#.', # 16
    '.#G#G#G#vvvvVVVVVVVVvvvv#G#G#G#.', # 17
    '..#####.##vvvvvvvvvvvv##.#####..', # 18
    '.........#ppppPPPPpppp#.........', # 19
    '.........#ppppPPPPpppp#.........', # 20
    '.........#ppp######ppp#.........', # 21
    '........#gG#......#gGG#.........', # 22 Left leg extending forward
    '.......#gGG#......#gGG#.........', # 23
    '.......#gg#........#gg#.........', # 24
    '.......##..........##...........', # 25 Tiptoe push
    '.......#gg#.....................', # 26 Left foot reaching down
    '........##......................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

frames_z1 = [z1_f1, z1_f2, z1_f3, z1_f4, z1_f5, z1_f6, z1_f7, z1_f8]

# Validate row and column count
for i, fr in enumerate(frames_z1):
    assert len(fr) == 32, f"Frame {i+1} has {len(fr)} rows"
    for r_idx, row in enumerate(fr):
        assert len(row) == 32, f"Frame {i+1} row {r_idx} len={len(row)}"

print("Zombie 1 (Reference Row 2) validated!")

# Render Zombie 1 32x32 images
images_z1_32 = []
for idx, fr in enumerate(frames_z1):
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    for y in range(32):
        for x in range(32):
            char = fr[y][x]
            color = PALETTE_ZOMBIE1.get(char, (0, 0, 0, 0))
            img.putpixel((x, y), color)
    frame_path = os.path.join(output_dir, f"zombie1_frame_{idx+1:02d}.png")
    img.save(frame_path)
    images_z1_32.append(img)

# Spritesheet (256x32)
sheet_z1_32 = Image.new("RGBA", (32 * 8, 32), (0, 0, 0, 0))
for idx, img in enumerate(images_z1_32):
    sheet_z1_32.paste(img, (idx * 32, 0))
sheet_z1_32.save(os.path.join(output_dir, "zombie1_walk_32x32_spritesheet.png"))

# Integer 8x Scaled versions
images_z1_256 = []
for idx, img in enumerate(images_z1_32):
    img_256 = img.resize((256, 256), Image.Resampling.NEAREST)
    img_256.save(os.path.join(output_dir, f"zombie1_frame_{idx+1:02d}_256px.png"))
    img_256.save(os.path.join(brain_dir, f"zombie1_frame_{idx+1:02d}.png"))
    images_z1_256.append(img_256)

sheet_z1_256 = sheet_z1_32.resize((256 * 8, 256), Image.Resampling.NEAREST)
sheet_z1_256.save(os.path.join(output_dir, "zombie1_walk_spritesheet_256px.png"))
sheet_z1_256.save(os.path.join(brain_dir, "zombie1_walk_spritesheet.png"))

# Animated GIFs (Native 32x32 & Scaled 256px)
# Background matched to reference floor dark purple (72, 68, 86)
ref_bg_color = (72, 68, 86, 255)

gif_z1_32_frames = []
for img in images_z1_32:
    bg = Image.new("RGBA", (32, 32), ref_bg_color)
    bg.paste(img, (0, 0), img)
    gif_z1_32_frames.append(bg)

gif_z1_32_frames[0].save(
    os.path.join(output_dir, "zombie1_walk_32x32.gif"),
    save_all=True,
    append_images=gif_z1_32_frames[1:],
    duration=110,
    loop=0
)

gif_z1_256_frames = []
for img in images_z1_256:
    bg = Image.new("RGBA", (256, 256), ref_bg_color)
    bg.paste(img, (0, 0), img)
    gif_z1_256_frames.append(bg)

gif_z1_256_path = os.path.join(output_dir, "zombie1_walk_256px.gif")
brain_gif_z1_path = os.path.join(brain_dir, "zombie1_walk_animated.gif")

gif_z1_256_frames[0].save(
    gif_z1_256_path,
    save_all=True,
    append_images=gif_z1_256_frames[1:],
    duration=110,
    loop=0
)
gif_z1_256_frames[0].save(
    brain_gif_z1_path,
    save_all=True,
    append_images=gif_z1_256_frames[1:],
    duration=110,
    loop=0
)

print("Zombie 1 assets created successfully!")
