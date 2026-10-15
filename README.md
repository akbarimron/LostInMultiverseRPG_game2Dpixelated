# 🌌 Lost in Multiverse RPG

[![Engine](https://img.shields.io/badge/Engine-Godot%204.7-blue.svg)](https://godotengine.org/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Android-green.svg)](#-platforms--installation)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Developer](https://img.shields.io/badge/Developer-%40Hibareit-orange.svg)](#-developer--socials)

> **Survive the unpredictable realms of the multiverse where every tile is a test of strategy, luck, and sharp battle reflexes!**

---

## 📖 About the Game

**Lost in Multiverse RPG** is a 2D retro board-crawler RPG built with **Godot Engine 4.7**. 

You are suddenly cast into a fractured multiverse where familiar city streets have been warped into a living board crawl teeming with high school zombies, imp tricksters, and ferocious multiverse demons. 

To survive and find your way back home, you must navigate branching paths, manage your inventory, roll the dice strategically, and master active parry timing in turn-based combat.

---

## ✨ Key Features

- 🎲 **Dynamic Board Exploration**: Travel across grid-based pathways. Choose your route through combat tiles, mystery chests, supply shops, and healing zones.
- ⚡ **Active QTE Parry & Defense System**: Classic turn-based RPG battles elevated with interactive reflexes! Time your reaction with the on-screen timing gauge to execute **Perfect Parries** and negate incoming enemy damage.
- 🎒 **Tactical Inventory & Bag Throwing**: Earn multiverse coins, buy potions and emergency gear at the shop, or throw items straight from your backpack during intense battles.
- 👾 **Charming 16-Bit Pixel Art**: Custom handcrafted pixel sprites, expressive monster animations, and a responsive pixel-styled UI.
- 📱💻 **Universal Cross-Platform (PC & Mobile)**: Fully responsive controls—play with keyboard & mouse on Windows PC or seamless touch controls (on-screen directional pad & tap-anywhere parry) on Android.
- 📖 **Interactive Field Guide**: Built-in guide book accessible anytime in-game explaining combat rules, enemy types, and multiverse exploration tips.

---

## 🕹️ Controls

### 🖥️ Windows PC
| Action | Controls |
| :--- | :--- |
| **Select Actions / Menu Buttons** | Mouse Left-Click or Number Keys `[1]` – `[4]` |
| **Choose Board Direction** | Arrow Keys or `[W] [A] [S] [D]` |
| **QTE Parry / Dodge** | Press `[Spacebar]` when the indicator enters the green zone |
| **Pause / System Menu** | `[Esc]` |

### 📱 Android (Mobile)
| Action | Controls |
| :--- | :--- |
| **Select Actions & Menus** | Tap directly on screen buttons |
| **Choose Board Direction** | Tap on-screen directional arrows `[←]` `[↑]` `[↓]` `[→]` |
| **QTE Parry / Dodge** | **Tap anywhere on the screen** when the bar hits the green zone |

---

## 📦 Project Structure

```
Programming_LostInMultiverseRPG/
├── assets/                     # Raw source assets & sprites
├── lostin-multiverserpg/        # Godot 4.7 game project directory
│   ├── project.godot           # Main Godot project configuration
│   ├── scenes/                 # Game scenes (title, board, battle, ending, etc.)
│   ├── scripts/                # GDScript source code (board, battle, core, UI)
│   ├── assets/                 # In-game textures, audio, fonts, and themes
│   └── export_presets.cfg      # Export presets for Windows Desktop & Android
├── tools/                      # Development & generation utility scripts (i18n, sfx, art)
├── .gitignore                  # Git ignore rules for Godot, builds, and caches
└── README.md                   # Project documentation
```

---

## 🚀 Running the Project

### Prerequisites
- [Godot Engine 4.7+](https://godotengine.org/download)

### Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/<username>/LostInMultiverseRPG.git
   ```
2. Open **Godot Engine 4.7**.
3. Click **Import**, navigate to `lostin-multiverserpg/project.godot`, and open the project.
4. Press **F5** to run the game!

---

## 👨‍💻 Developer & Socials

- **Game Developer**: **@Hibareit**
- **Instagram**: [@akbar_diy](https://instagram.com/akbar_diy)
- **Engine**: [Godot Engine](https://godotengine.org/)
- **itch.io**: Released for Windows PC and Android

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
