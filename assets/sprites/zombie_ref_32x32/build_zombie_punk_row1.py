import os
from PIL import Image

output_dir = r"d:\Project\Programming_LostInMultiverseRPG\assets\sprites\zombie_ref_32x32"
brain_dir = r"C:\Users\akbar\.gemini\antigravity\brain\4c54dd00-946b-4386-8e72-bc71621cdcf1"

PALETTE_ZOMBIE2 = {
    '.': (0, 0, 0, 0),             # Transparent
    '#': (47, 47, 46, 255),        # Deep charcoal outline
    'R': (226, 83, 56, 255),       # Wild red hair light
    'r': (180, 50, 36, 255),       # Wild red hair dark
    'P': (83, 55, 122, 255),       # Purple tunic / pants light
    'p': (67, 46, 96, 255),        # Purple tunic / pants dark
    'W': (218, 217, 204, 255),     # White bone / collar / teeth
    'w': (180, 180, 174, 255),     # White bone shadow
    'G': (109, 142, 110, 255),     # Green skin light
    'g': (90, 118, 91, 255),       # Green skin dark
    'E': (255, 255, 255, 255),     # Glowing eye white
    'K': (214, 48, 48, 255),       # Red belt light
    'k': (158, 30, 30, 255),       # Red belt dark
}

# 8 walk cycle frames for Red-Haired Bone-Arm Zombie (Row 1 from user reference)
# Frame 1: Contact 1
z2_f1 = [
    '................................', # 0
    '............##......##..........', # 1
    '...........#RR#....#RR#.........', # 2  Wild spiky red hair
    '..........#RRRR####RRRR#........', # 3
    '.........#rRRRRRRRRRRRRr#.......', # 4
    '........#rRRRRRRRRRRRRRRr#......', # 5
    '........#rRR#ggggGGGG#RRr#......', # 6  Green face framed in red hair
    '........#RR#gGGGGGGGG#RR#.......', # 7
    '.........##gG#E##gG#E#g##.......', # 8  Glowing white eyes in dark sockets
    '..........#gg#E##gG#E#g#........', # 9
    '..........#ggg####gg###g#.......', # 10 Open mouth
    '..........#ggg#WW#gg#WWg#.......', # 11 White teeth
    '..........##ggg##gggg##g#.......', # 12 Jaw
    '...........#gWWWWWWWWg#.........', # 13 White collar
    '....###...#pPPPPPPPPPPp#...##...', # 14 Shoulders & purple tunic
    '...#WwW#..#pPPPPPPPPPPp#..#PP#..', # 15 Left arm is EXPOSED WHITE BONE
    '..#WwwW#.#pPPPPPPPPPPPPp#.#PPG#.', # 16 Right arm is purple sleeve + green hand
    '..#WwwW#.#pPPPPPPPPPPPPp#.#GGG#.', # 17 Right hand pointing forward
    '...####..#kKKKKKKKKKKKk#...###..', # 18 Red waist belt
    '.........#ppppPPPPpppp#.........', # 19 Purple pants
    '.........#ppppPPPPpppp#.........', # 20
    '.........#ppp######ppp#.........', # 21 Split
    '........#gGG#......#gG#.........', # 22 Left foot forward, right foot back
    '........#gGG#......#gG#.........', # 23
    '.......#gGGG#.......#gg#........', # 24
    '.......#gGGG#.......#gg#........', # 25 Left foot flat
    '........####.........##.........', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 2: Down 1 (Recoil, Y+1)
z2_f2 = [
    '................................', # 0
    '................................', # 1
    '............##......##..........', # 2  (Everything dropped 1px)
    '...........#RR#....#RR#.........', # 3
    '..........#RRRR####RRRR#........', # 4
    '.........#rRRRRRRRRRRRRr#.......', # 5
    '........#rRRRRRRRRRRRRRRr#......', # 6
    '........#rRR#ggggGGGG#RRr#......', # 7
    '........#RR#gGGGGGGGG#RR#.......', # 8
    '.........##gG#E##gG#E#g##.......', # 9  Eyes
    '..........#gg#E##gG#E#g#........', # 10
    '..........#ggg####gg###g#.......', # 11
    '..........#ggg#WW#gg#WWg#.......', # 12
    '..........##ggg##gggg##g#.......', # 13
    '...........#gWWWWWWWWg#.........', # 14
    '....###...#pPPPPPPPPPPp#...##...', # 15
    '...#WwW#..#pPPPPPPPPPPp#..#PP#..', # 16
    '..#WwwW#.#pPPPPPPPPPPPPp#.#PPG#.', # 17
    '..#WwwW#.#pPPPPPPPPPPPPp#.#GGG#.', # 18
    '...####..#kKKKKKKKKKKKk#...###..', # 19
    '.........#ppppPPPPpppp#.........', # 20
    '.........#ppp######ppp#.........', # 21
    '........#gGG#.......##..........', # 22 Left knee bends
    '.......#gGGG#......#gG#.........', # 23 Right heel lifts
    '.......#gGGG#......#gg#.........', # 24
    '........####........##..........', # 25
    '................................', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 3: Passing 1 (Base Y)
z2_f3 = [
    '................................', # 0
    '............##......##..........', # 1
    '...........#RR#....#RR#.........', # 2
    '..........#RRRR####RRRR#........', # 3
    '.........#rRRRRRRRRRRRRr#.......', # 4
    '........#rRRRRRRRRRRRRRRr#......', # 5
    '........#rRR#ggggGGGG#RRr#......', # 6
    '........#RR#gGGGGGGGG#RR#.......', # 7
    '.........##gG#E##gG#E#g##.......', # 8
    '..........#gg#E##gG#E#g#........', # 9
    '..........#ggg####gg###g#.......', # 10
    '..........#ggg#WW#gg#WWg#.......', # 11
    '..........##ggg##gggg##g#.......', # 12
    '...........#gWWWWWWWWg#.........', # 13
    '....###...#pPPPPPPPPPPp#...##...', # 14
    '...#WwW#..#pPPPPPPPPPPp#..#PP#..', # 15
    '..#WwwW#.#pPPPPPPPPPPPPp#.#PPG#.', # 16
    '..#WwwW#.#pPPPPPPPPPPPPp#.#GGG#.', # 17
    '...####..#kKKKKKKKKKKKk#...###..', # 18
    '.........#ppppPPPPpppp#.........', # 19
    '.........#ppppPPPPpppp#.........', # 20
    '.........#ppppPPPPpppp#.........', # 21
    '........#gGG###gG#..............', # 22 Right leg passing center
    '........#gGG##gGG#..............', # 23
    '........#gGG##gg#...............', # 24
    '........#gGG#.#..#..............', # 25
    '.........####...................', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 4: Up 1 (High point, Y-1)
z2_f4 = [
    '............##......##..........', # 0  (Head up 1px!)
    '...........#RR#....#RR#.........', # 1
    '..........#RRRR####RRRR#........', # 2
    '.........#rRRRRRRRRRRRRr#.......', # 3
    '........#rRRRRRRRRRRRRRRr#......', # 4
    '........#rRR#ggggGGGG#RRr#......', # 5
    '........#RR#gGGGGGGGG#RR#.......', # 6
    '.........##gG#E##gG#E#g##.......', # 7
    '..........#gg#E##gG#E#g#........', # 8
    '..........#ggg####gg###g#.......', # 9
    '..........#ggg#WW#gg#WWg#.......', # 10
    '..........##ggg##gggg##g#.......', # 11
    '...........#gWWWWWWWWg#.........', # 12
    '....###...#pPPPPPPPPPPp#...##...', # 13
    '...#WwW#..#pPPPPPPPPPPp#..#PP#..', # 14
    '..#WwwW#.#pPPPPPPPPPPPPp#.#PPG#.', # 15
    '..#WwwW#.#pPPPPPPPPPPPPp#.#GGG#.', # 16
    '...####..#kKKKKKKKKKKKk#...###..', # 17
    '.........#ppppPPPPpppp#.........', # 18
    '.........#ppppPPPPpppp#.........', # 19
    '.........#ppp######ppp#.........', # 20
    '........#gGG#......#gG#.........', # 21 Right leg reaching forward
    '........#gGG#......#gGG#........', # 22
    '.........#gg#.......#gg#........', # 23
    '..........##.........##.........', # 24
    '....................#gg#........', # 25
    '.....................##.........', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 5: Contact 2 (Right foot forward, Left foot back, Base Y)
z2_f5 = [
    '................................', # 0
    '............##......##..........', # 1
    '...........#RR#....#RR#.........', # 2
    '..........#RRRR####RRRR#........', # 3
    '.........#rRRRRRRRRRRRRr#.......', # 4
    '........#rRRRRRRRRRRRRRRr#......', # 5
    '........#rRR#ggggGGGG#RRr#......', # 6
    '........#RR#gGGGGGGGG#RR#.......', # 7
    '.........##gG#E##gG#E#g##.......', # 8
    '..........#gg#E##gG#E#g#........', # 9
    '..........#ggg####gg###g#.......', # 10
    '..........#ggg#WW#gg#WWg#.......', # 11
    '..........##ggg##gggg##g#.......', # 12
    '...........#gWWWWWWWWg#.........', # 13
    '....###...#pPPPPPPPPPPp#...##...', # 14
    '...#WwW#..#pPPPPPPPPPPp#..#PP#..', # 15
    '..#WwwW#.#pPPPPPPPPPPPPp#.#PPG#.', # 16
    '..#WwwW#.#pPPPPPPPPPPPPp#.#GGG#.', # 17
    '...####..#kKKKKKKKKKKKk#...###..', # 18
    '.........#ppppPPPPpppp#.........', # 19
    '.........#ppppPPPPpppp#.........', # 20
    '.........#ppp######ppp#.........', # 21
    '........#gG#......#gGG#.........', # 22 Right foot forward, left back
    '........#gG#......#gGG#.........', # 23
    '.......#gg#.......#gGGG#........', # 24
    '.......#gg#.......#gGGG#........', # 25
    '........##.........####.........', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 6: Down 2 (Recoil, Y+1)
z2_f6 = [
    '................................', # 0
    '................................', # 1
    '............##......##..........', # 2  (Everything dropped 1px)
    '...........#RR#....#RR#.........', # 3
    '..........#RRRR####RRRR#........', # 4
    '.........#rRRRRRRRRRRRRr#.......', # 5
    '........#rRRRRRRRRRRRRRRr#......', # 6
    '........#rRR#ggggGGGG#RRr#......', # 7
    '........#RR#gGGGGGGGG#RR#.......', # 8
    '.........##gG#E##gG#E#g##.......', # 9
    '..........#gg#E##gG#E#g#........', # 10
    '..........#ggg####gg###g#.......', # 11
    '..........#ggg#WW#gg#WWg#.......', # 12
    '..........##ggg##gggg##g#.......', # 13
    '...........#gWWWWWWWWg#.........', # 14
    '....###...#pPPPPPPPPPPp#...##...', # 15
    '...#WwW#..#pPPPPPPPPPPp#..#PP#..', # 16
    '..#WwwW#.#pPPPPPPPPPPPPp#.#PPG#.', # 17
    '..#WwwW#.#pPPPPPPPPPPPPp#.#GGG#.', # 18
    '...####..#kKKKKKKKKKKKk#...###..', # 19
    '.........#ppppPPPPpppp#.........', # 20
    '.........#ppp######ppp#.........', # 21
    '.........##.......#gGG#.........', # 22 Right knee absorbs impact
    '........#gG#......#gGGG#........', # 23 Left heel lifts
    '........#gg#......#gGGG#........', # 24
    '.........##........####.........', # 25
    '................................', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 7: Passing 2 (Base Y)
z2_f7 = [
    '................................', # 0
    '............##......##..........', # 1
    '...........#RR#....#RR#.........', # 2
    '..........#RRRR####RRRR#........', # 3
    '.........#rRRRRRRRRRRRRr#.......', # 4
    '........#rRRRRRRRRRRRRRRr#......', # 5
    '........#rRR#ggggGGGG#RRr#......', # 6
    '........#RR#gGGGGGGGG#RR#.......', # 7
    '.........##gG#E##gG#E#g##.......', # 8
    '..........#gg#E##gG#E#g#........', # 9
    '..........#ggg####gg###g#.......', # 10
    '..........#ggg#WW#gg#WWg#.......', # 11
    '..........##ggg##gggg##g#.......', # 12
    '...........#gWWWWWWWWg#.........', # 13
    '....###...#pPPPPPPPPPPp#...##...', # 14
    '...#WwW#..#pPPPPPPPPPPp#..#PP#..', # 15
    '..#WwwW#.#pPPPPPPPPPPPPp#.#PPG#.', # 16
    '..#WwwW#.#pPPPPPPPPPPPPp#.#GGG#.', # 17
    '...####..#kKKKKKKKKKKKk#...###..', # 18
    '.........#ppppPPPPpppp#.........', # 19
    '.........#ppppPPPPpppp#.........', # 20
    '.........#ppppPPPPpppp#.........', # 21
    '..............#gG###gGG#........', # 22 Left leg passing center
    '.............#gGG##gGG#.........', # 23
    '..............#gg##gGG#.........', # 24
    '.............#..##gGG#..........', # 25
    '..................####..........', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 8: Up 2 (High point, Y-1)
z2_f8 = [
    '............##......##..........', # 0  (Head up 1px!)
    '...........#RR#....#RR#.........', # 1
    '..........#RRRR####RRRR#........', # 2
    '.........#rRRRRRRRRRRRRr#.......', # 3
    '........#rRRRRRRRRRRRRRRr#......', # 4
    '........#rRR#ggggGGGG#RRr#......', # 5
    '........#RR#gGGGGGGGG#RR#.......', # 6
    '.........##gG#E##gG#E#g##.......', # 7
    '..........#gg#E##gG#E#g#........', # 8
    '..........#ggg####gg###g#.......', # 9
    '..........#ggg#WW#gg#WWg#.......', # 10
    '..........##ggg##gggg##g#.......', # 11
    '...........#gWWWWWWWWg#.........', # 12
    '....###...#pPPPPPPPPPPp#...##...', # 13
    '...#WwW#..#pPPPPPPPPPPp#..#PP#..', # 14
    '..#WwwW#.#pPPPPPPPPPPPPp#.#PPG#.', # 15
    '..#WwwW#.#pPPPPPPPPPPPPp#.#GGG#.', # 16
    '...####..#kKKKKKKKKKKKk#...###..', # 17
    '.........#ppppPPPPpppp#.........', # 18
    '.........#ppppPPPPpppp#.........', # 19
    '.........#ppp######ppp#.........', # 20
    '........#gG#......#gGG#.........', # 21 Left leg extending forward
    '.......#gGG#......#gGG#.........', # 22
    '.......#gg#........#gg#.........', # 23
    '.......##..........##...........', # 24
    '.......#gg#.....................', # 25
    '........##......................', # 26
    '................................', # 27
    '................................', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

frames_z2 = [z2_f1, z2_f2, z2_f3, z2_f4, z2_f5, z2_f6, z2_f7, z2_f8]

# Validate
for i, fr in enumerate(frames_z2):
    assert len(fr) == 32, f"Frame {i+1} rows={len(fr)}"
    for r_idx, row in enumerate(fr):
        assert len(row) == 32, f"Frame {i+1} row {r_idx} len={len(row)}"

print("Zombie 2 (Reference Row 1) validated!")

# Render Zombie 2
images_z2_32 = []
for idx, fr in enumerate(frames_z2):
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    for y in range(32):
        for x in range(32):
            char = fr[y][x]
            color = PALETTE_ZOMBIE2.get(char, (0, 0, 0, 0))
            img.putpixel((x, y), color)
    frame_path = os.path.join(output_dir, f"zombie2_punk_frame_{idx+1:02d}.png")
    img.save(frame_path)
    images_z2_32.append(img)

# Spritesheet (256x32)
sheet_z2_32 = Image.new("RGBA", (32 * 8, 32), (0, 0, 0, 0))
for idx, img in enumerate(images_z2_32):
    sheet_z2_32.paste(img, (idx * 32, 0))
sheet_z2_32.save(os.path.join(output_dir, "zombie2_punk_walk_32x32_spritesheet.png"))

# Integer 8x Scaled versions
images_z2_256 = []
for idx, img in enumerate(images_z2_32):
    img_256 = img.resize((256, 256), Image.Resampling.NEAREST)
    img_256.save(os.path.join(output_dir, f"zombie2_punk_frame_{idx+1:02d}_256px.png"))
    img_256.save(os.path.join(brain_dir, f"zombie2_frame_{idx+1:02d}.png"))
    images_z2_256.append(img_256)

sheet_z2_256 = sheet_z2_32.resize((256 * 8, 256), Image.Resampling.NEAREST)
sheet_z2_256.save(os.path.join(output_dir, "zombie2_punk_walk_spritesheet_256px.png"))
sheet_z2_256.save(os.path.join(brain_dir, "zombie2_walk_spritesheet.png"))

# Animated GIFs
ref_bg_color = (72, 68, 86, 255)

gif_z2_32_frames = []
for img in images_z2_32:
    bg = Image.new("RGBA", (32, 32), ref_bg_color)
    bg.paste(img, (0, 0), img)
    gif_z2_32_frames.append(bg)

gif_z2_32_frames[0].save(
    os.path.join(output_dir, "zombie2_punk_walk_32x32.gif"),
    save_all=True,
    append_images=gif_z2_32_frames[1:],
    duration=110,
    loop=0
)

gif_z2_256_frames = []
for img in images_z2_256:
    bg = Image.new("RGBA", (256, 256), ref_bg_color)
    bg.paste(img, (0, 0), img)
    gif_z2_256_frames.append(bg)

gif_z2_256_path = os.path.join(output_dir, "zombie2_punk_walk_256px.gif")
brain_gif_z2_path = os.path.join(brain_dir, "zombie2_walk_animated.gif")

gif_z2_256_frames[0].save(
    gif_z2_256_path,
    save_all=True,
    append_images=gif_z2_256_frames[1:],
    duration=110,
    loop=0
)
gif_z2_256_frames[0].save(
    brain_gif_z2_path,
    save_all=True,
    append_images=gif_z2_256_frames[1:],
    duration=110,
    loop=0
)

print("Zombie 2 assets created successfully!")
