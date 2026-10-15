import os
from PIL import Image

output_dir = r"d:\Project\Programming_LostInMultiverseRPG\assets\sprites\zombie_walk_32x32"
brain_dir = r"C:\Users\akbar\.gemini\antigravity\brain\4c54dd00-946b-4386-8e72-bc71621cdcf1"
os.makedirs(output_dir, exist_ok=True)

PALETTE = {
    '.': (0, 0, 0, 0),          # Transparent
    '#': (18, 22, 18, 255),     # Silhouette outline
    'k': (38, 54, 38, 255),     # Skin shadow (dark green)
    'g': (66, 108, 60, 255),    # Skin mid (zombie green)
    'G': (112, 164, 84, 255),   # Skin light (lime green)
    'Y': (174, 202, 102, 255),  # Skin highlight
    'E': (255, 230, 40, 255),   # Glowing eye yellow
    'd': (36, 24, 44, 255),     # Shirt dark shadow
    'p': (82, 52, 102, 255),    # Shirt mid purple
    'P': (128, 86, 154, 255),   # Shirt highlight purple
    'j': (20, 26, 36, 255),     # Pants shadow / far leg
    'b': (42, 60, 86, 255),     # Pants mid blue
    'B': (70, 96, 134, 255),    # Pants highlight blue
    'w': (216, 210, 178, 255),  # Exposed bone / teeth
    's': (112, 106, 90, 255),   # Bone shadow
    'r': (154, 34, 34, 255),    # Blood red
    'f': (20, 24, 28, 255),     # Boot
}

# The 8 Walk Cycle Frames (each exactly 32 rows x 32 columns)

# Frame 1: Contact 1 (Left foot back, Right foot forward planted)
f1 = [
    '................................', # 0
    '................................', # 1
    '................................', # 2
    '................................', # 3
    '............######..............', # 4  Head top
    '...........#kkGgGg#.............', # 5
    '..........#kGGYGGYg#............', # 6  Forehead
    '..........#gG#E#YYg#............', # 7  Glowing eye
    '..........#ggGGGgkg#............', # 8  Cheek
    '..........#gg#w#r#g#............', # 9  Open mouth with tooth & blood
    '...........#g####g#.............', # 10 Jaw
    '..........##dd##gg#.............', # 11 Neck
    '........##ddppdd####............', # 12 Shoulders & back arm
    '.......#ddppPPpp####kgggg#......', # 13 Tattered shirt & arm reach
    '......#dpppPPPPP####kggg##......', # 14 Outstretched arm & dangling claw
    '.....#dppwPPPPPpd##.##g#........', # 15 Exposed bone
    '.....#dpwswpPPpd#...............', # 16 Shirt tear
    '......#dpppPpd#.................', # 17 Ragged hem
    '.......#ddpdd#..................', # 18 Waist
    '........#jjj#...................', # 19 Pelvis
    '.......#jbbj#...................', # 20 Thighs
    '......#jbb##bj#.................', # 21 Stride split
    '.....#jbb#..#bB#................', # 22
    '....#jbb#....#bB#...............', # 23
    '...#jgg#......#bB#..............', # 24 Rotten knee
    '..#jgg#........#bB#.............', # 25
    '..#ff#..........#gg#............', # 26
    '.#ffff#.........#ff#............', # 27
    '.#ffff#.........#ffff#..........', # 28
    '..####..........#ffff#..........', # 29 Feet on ground
    '.................####...........', # 30
    '................................'  # 31
]

# Frame 2: Down 1 (Weight on front foot, torso bobs down 1px, knee bends)
f2 = [
    '................................', # 0
    '................................', # 1
    '................................', # 2
    '................................', # 3
    '................................', # 4  (Empty due to 1px down bob)
    '............######..............', # 5  Head top (-1px)
    '...........#kkGgGg#.............', # 6
    '..........#kGGYGGYg#............', # 7
    '..........#gG#E#YYg#............', # 8  Glowing eye
    '..........#ggGGGgkg#............', # 9
    '..........#gg#w#r#g#............', # 10 Mouth
    '...........#g####g#.............', # 11
    '..........##dd##gg#.............', # 12 Neck
    '........##ddppdd####............', # 13 Torso
    '.......#ddppPPpp####kgggg#......', # 14 Arms sag slightly
    '......#dpppPPPPP####kggg##......', # 15
    '.....#dppwPPPPPpd##.##g#........', # 16
    '.....#dpwswpPPpd#...............', # 17
    '......#dpppPpd#.................', # 18
    '.......#ddpdd#..................', # 19
    '........#jjj#...................', # 20
    '.......#jbbj#...................', # 21
    '......#jbb##bB#.................', # 22 Front knee bent absorbing impact
    '.....#jbb#..#bB#................', # 23
    '....#jgg#....#bB#...............', # 24
    '...#jff#......#gg#..............', # 25 Back foot peeling up
    '..#ffff#......#ff#..............', # 26
    '..#fff#.......#ffff#............', # 27
    '...##.........#ffff#............', # 28
    '...............####.............', # 29 Front foot planted firm
    '................................', # 30
    '................................'  # 31
]

# Frame 3: Passing 1 (Weight centered, back leg swinging forward past knee)
f3 = [
    '................................', # 0
    '................................', # 1
    '................................', # 2
    '................................', # 3
    '............######..............', # 4  Head top
    '...........#kkGgGg#.............', # 5
    '..........#kGGYGGYg#............', # 6  Forehead
    '..........#gG#E#YYg#............', # 7  Eye
    '..........#ggGGGgkg#............', # 8
    '..........#gg#w#r#g#............', # 9  Mouth
    '...........#g####g#.............', # 10
    '..........##dd##gg#.............', # 11
    '........##ddppdd####............', # 12 Torso
    '.......#ddppPPpp####kgggg#......', # 13
    '......#dpppPPPPP####kggg##......', # 14
    '.....#dppwPPPPPpd##.##g#........', # 15
    '.....#dpwswpPPpd#...............', # 16
    '......#dpppPpd#.................', # 17
    '.......#ddpdd#..................', # 18
    '........#jjj#...................', # 19
    '.......#jbbj#...................', # 20
    '.......#bbbb#...................', # 21 Legs close together
    '......#jbb##bB#.................', # 22
    '.....#jbb#..#bB#................', # 23 Supporting leg straight
    '.....#jgg#..#bB#................', # 24 Swinging leg passing
    '.....#jff#..#gg#................', # 25
    '......##....#ff#................', # 26 Back foot in air
    '............#ffff#..............', # 27 Supporting foot on ground
    '............#ffff#..............', # 28
    '.............####...............', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 4: Up 1 (High point, supporting leg pushes up 1px, swinging leg reaches)
f4 = [
    '................................', # 0
    '................................', # 1
    '................................', # 2
    '............######..............', # 3  Head rises 1px up!
    '...........#kkGgGg#.............', # 4
    '..........#kGGYGGYg#............', # 5
    '..........#gG#E#YYg#............', # 6
    '..........#ggGGGgkg#............', # 7  Eye
    '..........#gg#w#r#g#............', # 8  Mouth
    '...........#g####g#.............', # 9
    '..........##dd##gg#.............', # 10
    '........##ddppdd####............', # 11 Torso rises
    '.......#ddppPPpp####kgggg#......', # 12
    '......#dpppPPPPP####kggg##......', # 13 Arms reach higher
    '.....#dppwPPPPPpd##.##g#........', # 14
    '.....#dpwswpPPpd#...............', # 15
    '......#dpppPpd#.................', # 16
    '.......#ddpdd#..................', # 17
    '........#jjj#...................', # 18
    '.......#jbbj#...................', # 19
    '......#jbb##bB#.................', # 20
    '.....#jbb#...#bB#...............', # 21
    '....#jgg#.....#bB#..............', # 22 Swinging leg extending forward
    '...#jff#.......#gg#.............', # 23
    '...#ff#........#ff#.............', # 24
    '....##.........#ffff#...........', # 25 Supporting foot tiptoe/push
    '...............#ffff#...........', # 26
    '................####............', # 27
    '................................', # 28
    '................#ffff#..........', # 29 Landing preparation
    '.................####...........', # 30
    '................................'  # 31
]

# Frame 5: Contact 2 (Opposite stride: Right foot back, Left foot forward planted)
f5 = [
    '................................', # 0
    '................................', # 1
    '................................', # 2
    '................................', # 3
    '............######..............', # 4  Head top
    '...........#kkGgGg#.............', # 5
    '..........#kGGYGGYg#............', # 6  Forehead
    '..........#gG#E#YYg#............', # 7  Glowing eye
    '..........#ggGGGgkg#............', # 8  Cheek
    '..........#gg#w#r#g#............', # 9  Open mouth with tooth & blood
    '...........#g####g#.............', # 10 Jaw
    '..........##dd##gg#.............', # 11 Neck
    '........##ddppdd####............', # 12 Upper torso & arm
    '.......#ddppPPpp####kgggg#......', # 13 Tattered shirt
    '......#dpppPPPPP####kggg##......', # 14 Outstretched arm & claw
    '.....#dppwPPPPPpd##.##g#........', # 15 Exposed bone
    '.....#dpwswpPPpd#...............', # 16
    '......#dpppPpd#.................', # 17
    '.......#ddpdd#..................', # 18
    '........#jjj#...................', # 19 Pelvis
    '.......#jbbj#...................', # 20 Thighs
    '......#bB##jbb#.................', # 21 Stride split (near leg back, far leg forward)
    '.....#bB#..#jbb#................', # 22
    '....#bB#....#jbb#...............', # 23
    '...#gg#......#jgg#..............', # 24
    '..#gg#........#jff#.............', # 25
    '..#ff#.........#ff#.............', # 26
    '.#ffff#........#ffff#...........', # 27
    '.#ffff#........#ffff#...........', # 28
    '..####..........#ffff#..........', # 29 Feet on ground
    '.................####...........', # 30
    '................................'  # 31
]

# Frame 6: Down 2 (Weight on opposite front foot, torso bobs down 1px)
f6 = [
    '................................', # 0
    '................................', # 1
    '................................', # 2
    '................................', # 3
    '................................', # 4  (Empty due to down bob)
    '............######..............', # 5  Head top (-1px)
    '...........#kkGgGg#.............', # 6
    '..........#kGGYGGYg#............', # 7
    '..........#gG#E#YYg#............', # 8  Eye
    '..........#ggGGGgkg#............', # 9
    '..........#gg#w#r#g#............', # 10 Mouth
    '...........#g####g#.............', # 11
    '..........##dd##gg#.............', # 12
    '........##ddppdd####............', # 13 Torso
    '.......#ddppPPpp####kgggg#......', # 14
    '......#dpppPPPPP####kggg##......', # 15
    '.....#dppwPPPPPpd##.##g#........', # 16
    '.....#dpwswpPPpd#...............', # 17
    '......#dpppPpd#.................', # 18
    '.......#ddpdd#..................', # 19
    '........#jjj#...................', # 20
    '.......#jbbj#...................', # 21
    '......#bB##jbb#.................', # 22 Front knee bent
    '.....#bB#..#jbb#................', # 23
    '....#gg#....#jgg#...............', # 24
    '...#ff#......#jff#..............', # 25 Back foot peeling up
    '..#ffff#.....#ffff#.............', # 26
    '..#fff#......#ffff#.............', # 27
    '...##.........####..............', # 28
    '................................', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 7: Passing 2 (Weight centered, near leg swinging forward past knee)
f7 = [
    '................................', # 0
    '................................', # 1
    '................................', # 2
    '................................', # 3
    '............######..............', # 4  Head top
    '...........#kkGgGg#.............', # 5
    '..........#kGGYGGYg#............', # 6  Forehead
    '..........#gG#E#YYg#............', # 7  Eye
    '..........#ggGGGgkg#............', # 8
    '..........#gg#w#r#g#............', # 9  Mouth
    '...........#g####g#.............', # 10
    '..........##dd##gg#.............', # 11
    '........##ddppdd####............', # 12 Torso
    '.......#ddppPPpp####kgggg#......', # 13
    '......#dpppPPPPP####kggg##......', # 14
    '.....#dppwPPPPPpd##.##g#........', # 15
    '.....#dpwswpPPpd#...............', # 16
    '......#dpppPpd#.................', # 17
    '.......#ddpdd#..................', # 18
    '........#jjj#...................', # 19
    '.......#jbbj#...................', # 20
    '.......#bbbb#...................', # 21 Legs passing
    '......#bB##jbb#.................', # 22
    '.....#bB#..#jbb#................', # 23 Supporting far leg straight
    '.....#gg#..#jgg#................', # 24 Near leg swinging forward
    '.....#ff#..#jff#................', # 25
    '......##....#ff#................', # 26
    '............#ffff#..............', # 27
    '............#ffff#..............', # 28 Supporting foot flat
    '.............####...............', # 29
    '................................', # 30
    '................................'  # 31
]

# Frame 8: Up 2 (High point, far leg pushes up 1px, near leg reaches forward)
f8 = [
    '................................', # 0
    '................................', # 1
    '................................', # 2
    '............######..............', # 3  Head rises 1px up!
    '...........#kkGgGg#.............', # 4
    '..........#kGGYGGYg#............', # 5
    '..........#gG#E#YYg#............', # 6
    '..........#ggGGGgkg#............', # 7  Eye
    '..........#gg#w#r#g#............', # 8  Mouth
    '...........#g####g#.............', # 9
    '..........##dd##gg#.............', # 10
    '........##ddppdd####............', # 11 Torso rises
    '.......#ddppPPpp####kgggg#......', # 12
    '......#dpppPPPPP####kggg##......', # 13 Arms reach forward
    '.....#dppwPPPPPpd##.##g#........', # 14
    '.....#dpwswpPPpd#...............', # 15
    '......#dpppPpd#.................', # 16
    '.......#ddpdd#..................', # 17
    '........#jjj#...................', # 18
    '.......#jbbj#...................', # 19
    '......#bB##jbb#.................', # 20
    '.....#bB#...#jbb#...............', # 21
    '....#gg#.....#jgg#..............', # 22 Near leg reaching out
    '...#ff#.......#jff#.............', # 23
    '...#ff#........#ff#.............', # 24
    '....##.........#ffff#...........', # 25 Supporting far leg tiptoe
    '...............#ffff#...........', # 26
    '................####............', # 27
    '................................', # 28
    '................#ffff#..........', # 29 Near foot preparing to plant
    '.................####...........', # 30
    '................................'  # 31
]

all_frames_data = [f1, f2, f3, f4, f5, f6, f7, f8]

# Validate all frames
for idx, fr in enumerate(all_frames_data):
    assert len(fr) == 32, f"Frame {idx+1} has {len(fr)} rows!"
    for r_idx, r in enumerate(fr):
        assert len(r) == 32, f"Frame {idx+1} row {r_idx} has len {len(r)}"

print("All 8 frames validated successfully!")

# Build 32x32 images
images_32 = []
for idx, fr in enumerate(all_frames_data):
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    for y in range(32):
        for x in range(32):
            char = fr[y][x]
            color = PALETTE.get(char, (0, 0, 0, 0))
            img.putpixel((x, y), color)
    frame_path = os.path.join(output_dir, f"frame_{idx+1:02d}.png")
    img.save(frame_path)
    images_32.append(img)
    print(f"Saved: {frame_path}")

# Build 32x32 Horizontal Sprite Sheet (32 * 8 = 256 px wide, 32 px tall)
sheet_32 = Image.new("RGBA", (32 * 8, 32), (0, 0, 0, 0))
for idx, img in enumerate(images_32):
    sheet_32.paste(img, (idx * 32, 0))

sheet_32_path = os.path.join(output_dir, "zombie_walk_32x32_spritesheet.png")
sheet_32.save(sheet_32_path)
print(f"Saved 32x32 spritesheet: {sheet_32_path}")

# Build 8x Scaled versions (256x256 per frame, 2048x256 spritesheet) with NEAREST NEIGHBOR (CRISP PIXELS)
images_256 = []
for idx, img in enumerate(images_32):
    img_256 = img.resize((256, 256), Image.Resampling.NEAREST)
    img_256_path = os.path.join(output_dir, f"frame_{idx+1:02d}_256px.png")
    img_256.save(img_256_path)
    # Also save to brain dir for markdown preview
    img_256.save(os.path.join(brain_dir, f"zombie32_frame_{idx+1:02d}.png"))
    images_256.append(img_256)

sheet_256 = sheet_32.resize((256 * 8, 256), Image.Resampling.NEAREST)
sheet_256_path = os.path.join(output_dir, "zombie_walk_spritesheet_256px.png")
sheet_256.save(sheet_256_path)
sheet_256.save(os.path.join(brain_dir, "zombie32_walk_spritesheet.png"))

# Create Animated GIFs
# 1) Native 32x32 GIF
gif_32_frames = []
for img in images_32:
    bg = Image.new("RGBA", (32, 32), (24, 28, 24, 255))
    bg.paste(img, (0, 0), img)
    gif_32_frames.append(bg)

gif_32_path = os.path.join(output_dir, "zombie_walk_32x32.gif")
gif_32_frames[0].save(
    gif_32_path,
    save_all=True,
    append_images=gif_32_frames[1:],
    duration=110, # ~9 FPS = 880ms for full walk cycle (ideal zombie shamble)
    loop=0
)

# 2) 8x Scaled 256x256 GIF for crisp chat & artifact preview
gif_256_frames = []
for img in images_256:
    bg = Image.new("RGBA", (256, 256), (24, 28, 24, 255))
    bg.paste(img, (0, 0), img)
    gif_256_frames.append(bg)

gif_256_path = os.path.join(output_dir, "zombie_walk_256px.gif")
brain_gif_path = os.path.join(brain_dir, "zombie_walk_32x32_animated.gif")

gif_256_frames[0].save(
    gif_256_path,
    save_all=True,
    append_images=gif_256_frames[1:],
    duration=110,
    loop=0
)
gif_256_frames[0].save(
    brain_gif_path,
    save_all=True,
    append_images=gif_256_frames[1:],
    duration=110,
    loop=0
)

print(f"Saved GIF: {gif_256_path}")
print("All 8-frame walk cycle assets completed!")
