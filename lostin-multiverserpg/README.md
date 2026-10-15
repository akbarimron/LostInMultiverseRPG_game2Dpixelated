# Lost in Multiverse RPG (prototipe v0.2)

Board-game RPG semi-horror: lempar dadu, jalan di papan berbentuk **labirin**, dan hadapi
apa pun yang ada di tiap kotak. Tiga dimensi: **Kota Kelam** (preman, begal, perampok),
**Dimensi Kegelapan** (iblis, pocong, tuyul), **Dimensi Tumor** (tumor, cacing parasit, mata).

## Kontrol
| Tombol | Fungsi |
|---|---|
| Spasi / Enter | Lempar dadu, konfirmasi, **PARRY** saat musuh menyerang |
| Panah / WASD / klik kotak | Pilih arah di persimpangan |
| I / Tab | Tas, perlengkapan, racik, kondisi, skill |
| M / klik minimap | Peta penuh + legenda |
| Esc | Menu jeda / kembali |
| 1-9 | Pilih cepat opsi menu |
| Z / scroll | Zoom papan |

## Mekanik utama
- **Papan labirin prosedural** per stage (maze + loop). Kotak: kroco, elite, boss/gerbang,
  harta karun (bisa terkunci / mimik), barang, pedagang, jebakan (sebagian tersembunyi),
  misteri (12 event + kuis edukatif), istirahat, altar, portal (stage 2+).
- **Pertarungan**: Serang (pilih bagian tubuh: kepala/badan/lengan/kaki, tiap bagian punya HP
  dan efek bila hancur), Bertahan, Skill (pakai Mind), Item, Kabur. Serangan musuh bisa
  di-**parry** dengan QTE (Perfect = balas serang, Tahan = damage -70%).
- **Status ala Fear & Hunger**: Pendarahan → Infeksi, Lengan/Kaki Patah, Racun/Racun Kuat,
  Cacing Parasit, Buta (peta hilang), Trauma (heal jadi damage), Terbakar, Bisu, Ketakutan I-III,
  Kegilaan (Mind 0 → halusinasi), Lapar I-V, Kutukan (dadu jadi 1), Benjolan Tumor, dll.
  Ada juga **fobia acak** yang memicu Ketakutan.
- **Perlengkapan**: senjata (1/2 tangan, efek berdarah/patah/terbakar), zirah, aksesori,
  crafting dari bahan, toko per stage, level up + skill baru.

## Struktur
```
scripts/core/    db.gd (semua data), game.gd (state & aturan), sfx.gd, transition.gd, theme_builder.gd
scripts/board/   board.gd (papan), board_gen.gd (generator labirin), board_events.gd, board_hud.gd
scripts/battle/  battle.gd
scripts/ui/      title, gameover, ending, dialog, tas, toko, peta, helper UI
assets/gen/      semua aset hasil generator (sprite, ikon, tile, UI, font, audio)
tools/           check_scripts.tscn (cek kompilasi), build_theme.gd (bake theme)
../tools/art/    generator pixel art Python (build.py), ../tools/sfx.py (audio)
```

## Regenerasi aset
```
python ../tools/art/build.py      # sprite, ikon, tile, UI, font -> assets/gen
python ../tools/sfx.py            # sfx + musik ambient -> assets/gen/audio
godot --headless --path . --script res://tools/build_theme.gd   # bake pixel_theme.tres
godot --headless --path . res://tools/check_scripts.tscn         # cek semua skrip
```
