<div align="center">

<!-- Animated Banner -->
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:00E5FF,50:7C3AED,100:00FF88&height=200&section=header&text=ARROWANCE&fontSize=80&fontColor=ffffff&fontAlignY=38&desc=The%20Neon%20Path%20Puzzle&descAlignY=60&descSize=22&animation=fadeIn" width="100%"/>

<!-- Badges Row 1 -->
<p>
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Riverpod-State_Mgmt-7C3AED?style=for-the-badge&logo=data:image/png;base64,&logoColor=white"/>
  <img src="https://img.shields.io/badge/Hive-Local_DB-FF6B00?style=for-the-badge&logoColor=white"/>
</p>

<!-- Badges Row 2 -->
<p>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-00E5FF?style=for-the-badge&logo=android&logoColor=white"/>
  <img src="https://img.shields.io/badge/Version-1.0.0-00FF88?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/License-MIT-FF2D78?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/PRs-Welcome-FFD700?style=for-the-badge"/>
</p>

<!-- Animated typing text -->
<a href="https://git.io/typing-svg">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=22&pause=1000&color=00E5FF&center=true&vCenter=true&width=700&lines=Guide+the+energy+through+the+only+valid+path.;Visit+every+node+exactly+once.;One+solution.+Infinite+challenge.;Think+fast.+Move+smart.+Solve+it." alt="Typing SVG"/>
</a>

<br/>

</div>

---

## 🌟 What is Arrowance?

**Arrowance** is a sleek, brain-teasing **neon path puzzle game** built with Flutter. It is based on the mathematics of **Hamiltonian path problems** — a classic computer science graph challenge where you must visit every node exactly once, from Start `S` to End `E`.

> *Relaxing at first glance. Ruthlessly logical underneath.*

The game rewards **pure reasoning** — no luck, no randomness. Every level has exactly **one valid solution**, and it's your job to find it.

---

## 📱 Screenshots & Game Flow

<div align="center">

| Gameplay Screen | Level Cleared | Out of Moves |
|:-:|:-:|:-:|
| ![Gameplay](https://via.placeholder.com/200x380/0D0F1A/00E5FF?text=LVL+2+%0A%0A%E2%97%8F%E2%86%92E%0A%E2%86%91%E2%97%8F%E2%97%8B%0AS%E2%86%90%E2%97%8F) | ![Cleared](https://via.placeholder.com/200x380/0D0F1A/00FF88?text=%E2%9C%93+Level%0ACleared!%0A%0A%E2%98%85+%E2%98%85+%E2%98%85%0APerfect!) | ![Fail](https://via.placeholder.com/200x380/0D0F1A/FF2D78?text=%F0%9F%92%94+Out+of%0AMoves!%0A%0ATry+Again) |
| *Navigate the grid carefully* | *3-star perfect solve* | *Wrong moves cost lives* |

</div>

---

## 🎮 Core Gameplay

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   ◉ ──→── ◉ ──→── E          RULES:                   │
│   │                           ✦ Start from  S (green)  │
│   ↑                           ✦ Reach       E (red)    │
│   │                           ✦ Visit EVERY node once  │
│   ◉ ──→── ◉ ──←── ◉          ✦ No node skipped        │
│                               ✦ One valid path only     │
│   S ──↑                                                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### How to Play

1. 🟢 **Start** at the green `S` node
2. 🔴 **Goal** is to reach the red `E` node
3. 🔵 **Visit every node** on the board — exactly once
4. 💡 **Plan your route** before tapping — wrong moves cost a life
5. ⭐ **Earn 3 stars** for a Perfect solve with no mistakes

---

## ✨ Key Features

<div align="center">

| Feature | Description |
|--------|-------------|
| 🧠 **Logic Puzzles** | Every level has exactly one correct Hamiltonian path |
| ⭐ **Star Rating** | Earn 1–3 stars based on accuracy and speed |
| 🔥 **Combo System** | Chain correct moves for combo multipliers (×2, ×4, ×8) |
| ❤️ **3-Life System** | Wrong moves penalized — think before you tap |
| ⏱️ **Timer Challenge** | Race against the clock; harder levels = more time |
| 💡 **Hint System** | Nudge in the right direction when stuck |
| ↩️ **Undo & Reset** | Refine your strategy without frustration |
| 📤 **Flex & Share** | Share your solve time and score with friends |
| 📳 **Haptic Feedback** | Satisfying vibration on every tap interaction |
| 📴 **Offline Play** | No internet required — play anywhere, anytime |
| 🎨 **Neon UI** | Beautiful dark interface with glowing node animations |
| 📈 **Progressive Difficulty** | Levels ramp up gradually — from simple to complex |

</div>

---

## 🛠️ Tech Stack

```
╔══════════════════════════════════════════════════════════════╗
║                    ARROWANCE TECH STACK                      ║
╠══════════════════╦═══════════════════════════════════════════╣
║  📱 Frontend     ║  Flutter 3.x (Android + iOS)             ║
║  🎯 Language     ║  Dart 3.x                                ║
║  ⚡ State Mgmt   ║  Riverpod (reactive + scalable)          ║
║  💾 Storage      ║  Hive (lightweight local DB)             ║
║  🎬 Animations   ║  Flutter Animate + Custom animations     ║
║  📳 Feedback     ║  Vibration (haptics) + Audio (planned)   ║
║  🧱 Architecture ║  Clean Architecture + Feature-first      ║
╚══════════════════╩═══════════════════════════════════════════╝
```

### Architecture Overview

```
lib/
├── 📁 core/
│   ├── 📁 engine/
│   │   ├── movement_logic.dart        # Arrow direction validation
│   │   ├── path_validator.dart        # Hamiltonian path checker
│   │   └── game_state.dart            # Core game state model
│   ├── 📁 constants/
│   │   └── app_colors.dart            # Neon color palette
│   └── 📁 utils/
│       └── level_parser.dart          # Level data parser
│
├── 📁 features/
│   ├── 📁 game/
│   │   ├── 📁 providers/              # Riverpod state providers
│   │   ├── 📁 widgets/                # Grid, Node, Arrow widgets
│   │   └── game_screen.dart           # Main gameplay screen
│   ├── 📁 level_select/
│   │   └── level_select_screen.dart   # Level picker
│   └── 📁 result/
│       ├── cleared_screen.dart        # Win screen
│       └── fail_screen.dart           # Lose screen
│
├── 📁 data/
│   ├── 📁 hive/                       # Hive adapters & boxes
│   └── 📁 levels/                     # Static level definitions
│
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

```bash
# Flutter SDK
flutter --version   # Should be 3.x or higher

# Dart SDK
dart --version      # Should be 3.x or higher

# Check all dependencies
flutter doctor
```

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/arrowance.git

# 2. Navigate to project directory
cd arrowance

# 3. Install dependencies
flutter pub get

# 4. Generate Hive adapters (if applicable)
flutter packages pub run build_runner build --delete-conflicting-outputs

# 5. Run the app
flutter run
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires Mac + Xcode)
flutter build ios --release
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.x.x       # Reactive state management
  riverpod_annotation: ^2.x.x    # Code generation for Riverpod

  # Local Storage
  hive: ^2.x.x                   # Lightweight NoSQL database
  hive_flutter: ^1.x.x           # Flutter integration for Hive

  # Animations
  flutter_animate: ^4.x.x        # Declarative animations

  # Feedback
  vibration: ^1.x.x              # Haptic feedback
  audioplayers: ^5.x.x           # Sound effects (optional)

  # Utils
  equatable: ^2.x.x              # Value equality
  freezed_annotation: ^2.x.x    # Immutable data classes

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.x.x
  hive_generator: ^2.x.x
  freezed: ^2.x.x
  riverpod_generator: ^2.x.x
  flutter_lints: ^3.x.x
```

---

## 🧩 Game Logic — How It Works

### Hamiltonian Path Algorithm

Arrowance is built on **Hamiltonian Path** theory from graph mathematics:

```dart
/// Validates if a path visits all nodes exactly once
/// from Start (S) to End (E)
bool isValidHamiltonianPath(List<Node> path, Graph graph) {
  // 1. Must start at S node
  if (path.first != graph.startNode) return false;

  // 2. Must end at E node
  if (path.last != graph.endNode) return false;

  // 3. Must visit every node exactly once
  if (path.length != graph.nodes.length) return false;

  // 4. Each consecutive pair must be connected
  for (int i = 0; i < path.length - 1; i++) {
    if (!graph.hasEdge(path[i], path[i + 1])) return false;
  }

  return true; // ✅ Valid path found!
}
```

### Movement Validation

```dart
/// Checks if an arrow move is valid in the current game state
MoveResult validateMove(Node from, Direction direction, GameState state) {
  final targetNode = getAdjacentNode(from, direction);

  if (targetNode == null)       return MoveResult.blocked;
  if (state.isVisited(targetNode)) return MoveResult.alreadyVisited;
  if (!state.hasEdge(from, targetNode)) return MoveResult.noConnection;

  return MoveResult.valid; // ✅ Move allowed
}
```

---

## 🗺️ Roadmap

```
Phase 1 — Foundation          ✅ COMPLETE
─────────────────────────────────────────
 ✅  Static level design (3×3 grids)
 ✅  Arrow movement logic
 ✅  Life system & countdown timer
 ✅  Level cleared / fail screens
 ✅  Star rating system
 ✅  Basic Hive local persistence

Phase 2 — Enhancement         🚧 IN PROGRESS
─────────────────────────────────────────────
 🔄  Combo multiplier (×2 / ×4 / ×8)
 🔄  Haptic & audio feedback polish
 🔄  Flex & Share result card
 🔄  Perfect detection badge
 🔄  Hint system
 ⏳  Undo & reset refinement

Phase 3 — Scale               📋 PLANNED
─────────────────────────────────────────
 📋  Procedural level generator
 📋  Expanded grid sizes (4×4, 5×5, 6×6)
 📋  Maze-style board rendering
 📋  Daily challenge mode
 📋  Leaderboard & social sharing
 📋  Achievements & XP system
 📋  Level editor (community levels)
```

---

## 🏆 Scoring System

```
┌────────────────────────────────────────────────┐
│              SCORING BREAKDOWN                 │
├──────────────────┬─────────────────────────────┤
│  ⭐⭐⭐ Perfect   │  No wrong moves + fast time │
│  ⭐⭐   Great    │  1 mistake OR slow time      │
│  ⭐     Complete │  2 mistakes OR very slow     │
│  💔     Failed   │  3 wrong moves = level lost  │
├──────────────────┴─────────────────────────────┤
│  🔥 Combo ×2   →  2 correct moves in a row     │
│  🔥 Combo ×4   →  4 correct moves in a row     │
│  🔥 Combo ×8   →  8 correct moves in a row     │
└────────────────────────────────────────────────┘
```

---

## 🎨 Design System

### Color Palette

```dart
// arrowance_colors.dart
class ArrowanceColors {
  // Primary
  static const neonCyan    = Color(0xFF00E5FF); // Active nodes, UI accents
  static const neonGreen   = Color(0xFF00FF88); // Start node (S), success
  static const neonPink    = Color(0xFFFF2D78); // End node (E), danger
  static const neonPurple  = Color(0xFFA78BFA); // Secondary nodes, highlights
  static const neonOrange  = Color(0xFFFF6B00); // Combo indicators

  // Backgrounds
  static const bgDark      = Color(0xFF0D0F1A); // Primary background
  static const bgCard      = Color(0xFF141726); // Card surfaces
  static const bgCard2     = Color(0xFF1A1F35); // Elevated cards

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textMuted   = Color(0xFF8892B0);
  static const textLight   = Color(0xFFCCD6F6);
}
```

### Typography

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Game Title | `Arial Black` | 36px | 900 |
| Level HUD | `Calibri` | 18px | 700 |
| Node Labels | `Arial Black` | 20px | 900 |
| Body Text | `Calibri` | 14px | 400 |
| Score/Time | `Monospace` | 22px | 700 |

---

## 🤝 Contributing

Contributions are warmly welcome! Here's how to get involved:

```bash
# 1. Fork the repository
# 2. Create a feature branch
git checkout -b feature/your-feature-name

# 3. Make your changes and commit
git commit -m "feat: add your feature description"

# 4. Push to your fork
git push origin feature/your-feature-name

# 5. Open a Pull Request 🎉
```

### Contribution Guidelines

- Follow **Clean Architecture** principles
- Use **Riverpod** for all state management
- Write widget tests for new game logic
- Follow Dart's official **linting rules** (`flutter_lints`)
- Use **conventional commits**: `feat:`, `fix:`, `docs:`, `refactor:`

---

## 🐛 Bug Reports & Feature Requests

Found a bug or have an idea? [Open an issue](https://github.com/yourusername/arrowance/issues) with:

- 📋 **Bug**: Steps to reproduce, expected vs actual behavior, device info
- 💡 **Feature**: What problem it solves, proposed implementation idea

---

## 📊 Project Stats

<div align="center">

![GitHub Stars](https://img.shields.io/github/stars/yourusername/arrowance?style=for-the-badge&color=FFD700&logo=github)
![GitHub Forks](https://img.shields.io/github/forks/yourusername/arrowance?style=for-the-badge&color=00E5FF&logo=github)
![GitHub Issues](https://img.shields.io/github/issues/yourusername/arrowance?style=for-the-badge&color=FF2D78&logo=github)
![GitHub Last Commit](https://img.shields.io/github/last-commit/yourusername/arrowance?style=for-the-badge&color=00FF88&logo=github)

</div>

---

## 📄 License

```
MIT License

Copyright (c) 2025 Arrowance

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software.
```

---

## 👨‍💻 About the Developer

<div align="center">

Built with ❤️ and lots of ☕ for puzzle enthusiasts who love mathematical challenges.

**Arrowance** — *Because every problem has exactly one elegant solution.*

<br/>

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:00FF88,50:7C3AED,100:00E5FF&height=120&section=footer&animation=fadeIn" width="100%"/>

</div>
