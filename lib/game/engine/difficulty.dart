// lib/game/engine/difficulty.dart
//
// Research-backed difficulty scaling.
// Key insight: distraction DENSITY (traps per node) drives addictiveness.
// We aim for max cognitive load without crossing into "unfair" territory.

import 'dart:math' as math;

enum DifficultyTier {
  tutorial('Tutorial'),
  easy('Easy'),
  medium('Medium'),
  hard('Hard'),
  expert('Expert');

  final String label;
  const DifficultyTier(this.label);
}

class DifficultyConfig {
  final DifficultyTier tier;
  final int gridCols;
  final int gridRows;
  final int maxDistractions;           // max total trap edges
  final int timeSeconds;               // hard time limit
  final double trapsPerJunction;       // avg traps per solution node (0-3)
  final int endRushTraps;              // how many "go directly to E" traps
  final int forwardSkipMin;            // minimum skip gap for trap edges
  final bool guaranteeBranchingEvery; // ensure branch every N nodes
  final int branchGuaranteeN;         // the N above

  const DifficultyConfig({
    required this.tier,
    required this.gridCols,
    required this.gridRows,
    required this.maxDistractions,
    required this.timeSeconds,
    this.trapsPerJunction = 0.5,
    this.endRushTraps = 0,
    this.forwardSkipMin = 2,
    this.guaranteeBranchingEvery = false,
    this.branchGuaranteeN = 4,
  });

  int get totalNodes => gridCols * gridRows;

  // ── Research-calibrated difficulty curve ─────────────────────────────────
  // Levels 1-3:   pure path, zero traps → build muscle memory
  // Levels 4-8:   1-2 traps → introduce the mechanic
  // Levels 9-20:  guarantees branching → every move is a real decision
  // Levels 21-35: dense traps + end rushes → Zeigarnik "almost there" traps
  // Levels 36+:   maximum cognitive load, multiple end shortcuts visible

  static DifficultyConfig forLevel(int level) {
    if (level <= 3) {
      return DifficultyConfig(
        tier: DifficultyTier.tutorial,
        gridCols: 3, gridRows: 3,
        maxDistractions: 0,
        timeSeconds: 60,
        trapsPerJunction: 0.0,
        endRushTraps: 0,
      );
    }

    if (level <= 8) {
      final s = level - 3; // 1..5
      return DifficultyConfig(
        tier: DifficultyTier.easy,
        gridCols: 3 + (s ~/ 3),
        gridRows: 3 + (s ~/ 2),
        maxDistractions: s,
        timeSeconds: 75,
        trapsPerJunction: 0.25,
        endRushTraps: s >= 4 ? 1 : 0,
        forwardSkipMin: 2,
      );
    }

    if (level <= 20) {
      final s = level - 8; // 1..12
      return DifficultyConfig(
        tier: DifficultyTier.medium,
        gridCols: 4 + (s ~/ 4),
        gridRows: 4 + (s ~/ 4),
        maxDistractions: 4 + s * 2,
        timeSeconds: 90 + s * 5,
        trapsPerJunction: 0.6,
        endRushTraps: 1 + s ~/ 4,
        forwardSkipMin: 2,
        guaranteeBranchingEvery: s >= 6,
        branchGuaranteeN: 3,
      );
    }

    if (level <= 35) {
      final s = math.min(level - 20, 15); // 1..15
      return DifficultyConfig(
        tier: DifficultyTier.hard,
        gridCols: math.min(5 + s ~/ 4, 9),
        gridRows: math.min(5 + s ~/ 4, 9),
        maxDistractions: 10 + s * 2,
        timeSeconds: math.min(120 + s * 4, 180),
        trapsPerJunction: 1.0,        // ~1 trap per decision point
        endRushTraps: 2 + s ~/ 4,    // multiple "almost there!" traps
        forwardSkipMin: 2,
        guaranteeBranchingEvery: true,
        branchGuaranteeN: 2,          // branch every 2 nodes
      );
    }

    // Expert: level 36+
    final s = math.min(level - 35, 20);
    final cols = math.min(7 + s ~/ 6, 10);
    final rows = math.min(7 + s ~/ 6, 10);
    return DifficultyConfig(
      tier: DifficultyTier.expert,
      gridCols: cols,
      gridRows: rows,
      maxDistractions: 20 + s * 3,
      timeSeconds: 180,
      trapsPerJunction: 1.5,         // up to 2 traps per junction
      endRushTraps: 3 + s ~/ 4,     // cluster of end-rush traps near goal
      forwardSkipMin: 1,             // even 1-step skips are traps now
      guaranteeBranchingEvery: true,
      branchGuaranteeN: 1,           // EVERY node has a trap
    );
  }
}
