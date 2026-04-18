// lib/game/engine/level_generator.dart
//
// ═══════════════════════════════════════════════════════════════
// RESEARCH-BACKED ADDICTIVE PUZZLE GENERATOR
// ═══════════════════════════════════════════════════════════════
//
// Psychological principles applied:
//
//  1. ZEIGARNIK EFFECT — Every trap makes the player feel "just one step away"
//     from the end. Particularly the end-rush traps (pointing directly to E)
//     trigger the "I can see it!" response before yanking victory away.
//
//  2. INTERMITTENT REINFORCEMENT — Trap density varies per junction so some
//     nodes are easy (one option) and others have 3 choices. The uncertainty
//     drives repeated engagement.
//
//  3. DEDUCTIVE > GUESSING — Traps are grid-adjacent (physically reachable)
//     but logically wrong (they orphan other unvisited nodes). The player can
//     REASON their way to the answer rather than click randomly.
//
//  4. FIVE TRAP TYPES for maximum deception:
//     A. FORWARD-SKIP: jump 2-4 steps ahead, orphaning middle nodes
//     B. END-RUSH:     arrow pointing to E from mid-path (Zeigarnik lure)
//     C. CLUSTER:      dense 2-3 traps at the same junction (paradox of choice)
//     D. PROXIMITY:    from nodes 2-4 hops before E, provide short paths to E
//     E. CROSSLINK:    same-row/same-col long-range connector (looks systematic)
//
//  5. WARNSDORFF-INSPIRED PATH GENERATION — The solution path is generated
//     using a variation of Warnsdorff's rule for Knight's Tour: at each step
//     prefer the neighbour with the FEWEST onward options. This creates a
//     winding, non-obvious path that players cannot predict visually.
//
// The result: every level is a genuinely hard spatial reasoning problem that
// provides the "aha!" dopamine hit when solved correctly.

import 'dart:math' as math;
import '../models/graph_models.dart';
import 'difficulty.dart';
import 'level_solver.dart';

class LevelGenerator {
  final LevelSolver _solver;
  const LevelGenerator(this._solver);

  LevelGraph generateLevel({
    required int levelNumber,
    required int seed,
    required DifficultyConfig config,
  }) {
    final graph = _build(levelNumber: levelNumber, seed: seed, config: config);
    assert(_solver.solveGraph(graph), 'BUG: generated graph is not solvable');
    return graph;
  }

  LevelGraph _build({
    required int levelNumber,
    required int seed,
    required DifficultyConfig config,
  }) {
    final rng  = math.Random(seed);
    final cols = math.min(config.gridCols, 10);
    final rows = math.min(config.gridRows, 10);

    // ── Build all nodes ───────────────────────────────────────────────────
    final nodes = <String, PuzzleNode>{};
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final id = 'n${x}_$y';
        nodes[id] = PuzzleNode(id: id, gridX: x, gridY: y);
      }
    }

    // ── Generate Hamiltonian path (Warnsdorff-inspired for non-linearity) ─
    final solutionPath = _warnsdorffPath(nodes, cols, rows, rng)
        ?? _backtrackPath(nodes, cols, rows, rng)
        ?? _snakePath(cols, rows, rng);

    // Position index for distraction logic
    final posOf = <String, int>{
      for (int i = 0; i < solutionPath.length; i++) solutionPath[i]: i,
    };

    // ── Wire solution edges (prepended → solver walks them first) ─────────
    final edges = <String, PuzzleEdge>{};
    for (int i = 0; i < solutionPath.length - 1; i++) {
      final fId = solutionPath[i];
      final tId = solutionPath[i + 1];
      final eId = 's_${fId}_$tId';
      edges[eId] = PuzzleEdge(
        id: eId, fromNodeId: fId, toNodeId: tId,
        direction: _dir(nodes[fId]!, nodes[tId]!),
        isSolutionEdge: true,
      );
      nodes[fId] = nodes[fId]!.copyWith(
        outgoingEdgeIds: [eId, ...nodes[fId]!.outgoingEdgeIds],
      );
    }

    nodes[solutionPath.first] = nodes[solutionPath.first]!.copyWith(type: NodeType.start);
    nodes[solutionPath.last]  = nodes[solutionPath.last]!.copyWith(type: NodeType.end);

    // ── Add all five trap types ────────────────────────────────────────────
    if (config.maxDistractions > 0) {
      _addForwardSkipTraps(nodes, edges, solutionPath, posOf, config, rng);
      _addEndRushTraps(nodes, edges, solutionPath, posOf, config, rng);
      _addClusterTraps(nodes, edges, solutionPath, posOf, config, rng);
      _addProximityTraps(nodes, edges, solutionPath, posOf, config, rng);
      _addCrosslinkTraps(nodes, edges, solutionPath, posOf, config, rng);
      if (config.guaranteeBranchingEvery) {
        _guaranteeBranching(nodes, edges, solutionPath, posOf, config, rng);
      }
    }

    return LevelGraph(
      levelNumber: levelNumber,
      gridCols: cols, gridRows: rows, seed: seed,
      nodes: nodes, edges: edges,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // PATH GENERATION
  // ════════════════════════════════════════════════════════════════

  // ── Warnsdorff-inspired: at each step pick the neighbour with
  //    the fewest UNVISITED neighbours (creates winding path) ─────────────
  List<String>? _warnsdorffPath(
      Map<String, PuzzleNode> nodes, int cols, int rows, math.Random rng) {
    if (cols * rows > 36) return null; // too slow for large grids

    final total = cols * rows;
    // Try multiple random starts, return first success
    final starts = List.generate(total, (i) => 'n${i % cols}_${i ~/ cols}')
      ..shuffle(rng);

    for (final startId in starts.take(6)) {
      final path    = [startId];
      final visited = <String>{startId};
      int stepsBacktracked = 0;

      bool walk(String cur) {
        if (stepsBacktracked++ > 15000) return false; // Prevent freeze
        if (path.length == total) return true;

        // Score each neighbour by how many unvisited neighbours IT has

        final nbrs = _rawNbrs(nodes[cur]!, nodes);
        final candidates = nbrs.where((n) => !visited.contains(n)).toList();
        if (candidates.isEmpty) return false;

        // Warnsdorff: sort by ascending onward-move count, shuffle ties
        candidates.sort((a, b) {
          final aCount = _rawNbrs(nodes[a]!, nodes)
              .where((n) => !visited.contains(n)).length;
          final bCount = _rawNbrs(nodes[b]!, nodes)
              .where((n) => !visited.contains(n)).length;
          return aCount.compareTo(bCount);
        });

        // Add slight randomness to break boring patterns
        if (candidates.length > 1 && rng.nextDouble() < 0.3) {
          final tmp = candidates[0];
          candidates[0] = candidates[1];
          candidates[1] = tmp;
        }

        for (final next in candidates) {
          visited.add(next);
          path.add(next);
          if (walk(next)) return true;
          path.removeLast();
          visited.remove(next);
        }
        return false;
      }

      if (walk(startId)) return path;
    }
    return null;
  }

  // ── Standard backtracking DFS with shuffle ────────────────────────────
  List<String>? _backtrackPath(
      Map<String, PuzzleNode> nodes, int cols, int rows, math.Random rng) {
    if (cols * rows > 49) return null;
    final startX = rng.nextInt(cols);
    final startY = rng.nextInt(rows);
    final start  = 'n${startX}_$startY';
    final path   = [start];
    final visited = {start};
    int stepsBacktracked = 0;

    bool dfs(String cur) {
      if (stepsBacktracked++ > 5000) return false; // Prevent freeze
      if (path.length == cols * rows) return true;
      final nbrs = _rawNbrs(nodes[cur]!, nodes)..shuffle(rng);

      for (final n in nbrs) {
        if (!visited.contains(n)) {
          visited.add(n); path.add(n);
          if (dfs(n)) return true;
          path.removeLast(); visited.remove(n);
        }
      }
      return false;
    }

    return dfs(start) ? path : null;
  }

  // ── Boustrophedon snake (always succeeds) ─────────────────────────────
  List<String> _snakePath(int cols, int rows, math.Random rng) {
    final path = <String>[];
    if (rng.nextBool()) {
      final flip = rng.nextBool();
      for (int ri = 0; ri < rows; ri++) {
        final y = flip ? rows - 1 - ri : ri;
        final xs = ri % 2 == 0
            ? List.generate(cols, (x) => x)
            : List.generate(cols, (x) => cols - 1 - x);
        for (final x in xs) { path.add('n${x}_$y'); }
      }
    } else {
      final flip = rng.nextBool();
      for (int ci = 0; ci < cols; ci++) {
        final x = flip ? cols - 1 - ci : ci;
        final ys = ci % 2 == 0
            ? List.generate(rows, (y) => y)
            : List.generate(rows, (y) => rows - 1 - y);
        for (final y in ys) { path.add('n${x}_$y'); }
      }
    }
    return path;
  }

  // ════════════════════════════════════════════════════════════════
  // TRAP TYPE A — FORWARD SKIP
  // ════════════════════════════════════════════════════════════════
  // Jump ahead on the path, orphaning intermediate nodes.
  // DECEPTIVE because the target looks like valid progress.
  void _addForwardSkipTraps(
    Map<String, PuzzleNode> nodes, Map<String, PuzzleEdge> edges,
    List<String> path, Map<String, int> posOf,
    DifficultyConfig config, math.Random rng,
  ) {
    final budget = (config.maxDistractions * 0.35).ceil();
    int added = 0;
    final shuffled = [...path]..shuffle(rng);

    for (final fromId in shuffled) {
      if (added >= budget) break;
      if (nodes[fromId]!.type == NodeType.end) continue;
      final fromPos = posOf[fromId]!;

      final nbrs = _rawNbrs(nodes[fromId]!, nodes)..shuffle(rng);
      for (final toId in nbrs) {
        if (added >= budget) break;
        final toPos = posOf[toId]!;
        // Gap of 2..5 — meaningful skip
        final gap = toPos - fromPos;
        if (gap < config.forwardSkipMin || gap > 5) continue;
        if (_edgeExists(nodes[fromId]!, edges, toId)) continue;

        _addTrap(nodes, edges, fromId, toId);
        added++;
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // TRAP TYPE B — END RUSH (THE ZEIGARNIK LURE)
  // ════════════════════════════════════════════════════════════════
  // Direct arrow from mid-path → END node.
  // Creates "I can see the finish!" before orphaning remaining nodes.
  void _addEndRushTraps(
    Map<String, PuzzleNode> nodes, Map<String, PuzzleEdge> edges,
    List<String> path, Map<String, int> posOf,
    DifficultyConfig config, math.Random rng,
  ) {
    final endId   = path.last;
    final endNode = nodes[endId]!;
    final budget  = config.endRushTraps;
    int added = 0;

    // Look for any node adjacent to END that is NOT the penultimate node
    final adjacentToEnd = _rawNbrs(endNode, nodes)
        .where((id) => id != path[path.length - 2])
        .toList()..shuffle(rng);

    for (final fromId in adjacentToEnd) {
      if (added >= budget) break;
      if (_edgeExists(nodes[fromId]!, edges, endId)) continue;
      _addTrap(nodes, edges, fromId, endId);
      added++;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // TRAP TYPE C — CLUSTER BRANCHING (PARADOX OF CHOICE)
  // ════════════════════════════════════════════════════════════════
  // 2-3 traps at the SAME junction node.
  // Players face 3 arrows and get paralysed — classic Schwartz paradox.
  void _addClusterTraps(
    Map<String, PuzzleNode> nodes, Map<String, PuzzleEdge> edges,
    List<String> path, Map<String, int> posOf,
    DifficultyConfig config, math.Random rng,
  ) {
    if (config.trapsPerJunction < 0.8) return; // only medium+
    final budget = (config.maxDistractions * 0.20).ceil();
    int added = 0;

    // Pick a few "cluster junction" nodes in the first 60% of path
    final junctionCandidates = path
        .where((id) {
          final pos = posOf[id]!;
          return pos > 2 && pos < path.length * 0.6;
        })
        .toList()..shuffle(rng);

    for (final fromId in junctionCandidates.take(3)) {
      if (added >= budget) break;
      final fromPos = posOf[fromId]!;
      final nbrs = _rawNbrs(nodes[fromId]!, nodes)..shuffle(rng);
      int clusterAdded = 0;

      for (final toId in nbrs) {
        if (added >= budget || clusterAdded >= 2) break;
        final toPos = posOf[toId]!;
        if (toPos <= fromPos + 1) continue;
        if (_edgeExists(nodes[fromId]!, edges, toId)) continue;

        _addTrap(nodes, edges, fromId, toId);
        added++;
        clusterAdded++;
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // TRAP TYPE D — PROXIMITY TRAPS (NEAR-MISS PRESSURE)
  // ════════════════════════════════════════════════════════════════
  // From nodes 3-6 positions before END, add traps that point NEAR end.
  // Creates the "I'm so close!" illusion near the endgame.
  void _addProximityTraps(
    Map<String, PuzzleNode> nodes, Map<String, PuzzleEdge> edges,
    List<String> path, Map<String, int> posOf,
    DifficultyConfig config, math.Random rng,
  ) {
    if (config.endRushTraps < 2) return;
    final budget = (config.maxDistractions * 0.20).ceil();
    final endPos = path.length - 1;
    int added = 0;

    // Nodes in the last 25% of path (excluding end itself)
    final nearEnd = path
        .where((id) {
          final pos = posOf[id]!;
          return pos >= (endPos * 0.75).round() && pos < endPos - 1;
        })
        .toList()..shuffle(rng);

    for (final fromId in nearEnd) {
      if (added >= budget) break;
      final fromPos = posOf[fromId]!;
      final nbrs = _rawNbrs(nodes[fromId]!, nodes)..shuffle(rng);

      for (final toId in nbrs) {
        if (added >= budget) break;
        final toPos = posOf[toId]!;
        // Must jump past at least 1 unvisited node
        if (toPos <= fromPos + 1 || toPos > endPos) continue;
        if (_edgeExists(nodes[fromId]!, edges, toId)) continue;

        _addTrap(nodes, edges, fromId, toId);
        added++;
        break; // one per near-end node
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // TRAP TYPE E — CROSSLINK TRAPS (SYSTEMATIC ILLUSION)
  // ════════════════════════════════════════════════════════════════
  // Connect nodes in the same grid row OR column that are far apart on path.
  // Looks like a "logical" systematic connection, but it orphans middle nodes.
  void _addCrosslinkTraps(
    Map<String, PuzzleNode> nodes, Map<String, PuzzleEdge> edges,
    List<String> path, Map<String, int> posOf,
    DifficultyConfig config, math.Random rng,
  ) {
    if (config.trapsPerJunction < 0.6) return;
    final budget = (config.maxDistractions * 0.15).ceil();
    int added = 0;

    final allNodes = nodes.values.toList()..shuffle(rng);

    for (final fromNode in allNodes) {
      if (added >= budget) break;
      final fromId  = fromNode.id;
      final fromPos = posOf[fromId]!;
      if (nodes[fromId]!.type == NodeType.end) continue;

      // Look for SAME-ROW neighbour that is far ahead on path
      final sameRow = nodes.values.where((n) =>
          n.gridY == fromNode.gridY &&
          (n.gridX - fromNode.gridX).abs() == 1 &&
          posOf[n.id]! > fromPos + 3
      ).toList();

      // Look for SAME-COL neighbour that is far ahead on path
      final sameCol = nodes.values.where((n) =>
          n.gridX == fromNode.gridX &&
          (n.gridY - fromNode.gridY).abs() == 1 &&
          posOf[n.id]! > fromPos + 3
      ).toList();

      final candidates = [...sameRow, ...sameCol]..shuffle(rng);

      for (final toNode in candidates.take(1)) {
        if (_edgeExists(nodes[fromId]!, edges, toNode.id)) continue;
        _addTrap(nodes, edges, fromId, toNode.id);
        added++;
        break;
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // GUARANTEED BRANCHING — Every N solution nodes MUST have a trap
  // ════════════════════════════════════════════════════════════════
  void _guaranteeBranching(
    Map<String, PuzzleNode> nodes, Map<String, PuzzleEdge> edges,
    List<String> path, Map<String, int> posOf,
    DifficultyConfig config, math.Random rng,
  ) {
    final n = config.branchGuaranteeN;

    for (int i = 0; i < path.length - 1; i += n) {
      final fromId  = path[i];
      final fromNode = nodes[fromId]!;
      if (fromNode.type == NodeType.end) continue;

      // Skip if already has a distraction
      final hasDistraction = fromNode.outgoingEdgeIds.any((eid) {
        final e = edges[eid];
        return e != null && !e.isSolutionEdge;
      });
      if (hasDistraction) continue;

      // Find any unvisited-ahead neighbour with gap >= 2
      final nbrs = _rawNbrs(fromNode, nodes)..shuffle(rng);
      for (final toId in nbrs) {
        final toPos = posOf[toId]!;
        final fromPos = posOf[fromId]!;
        if (toPos <= fromPos + 1) continue;
        if (_edgeExists(fromNode, edges, toId)) continue;
        _addTrap(nodes, edges, fromId, toId);
        break;
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════

  void _addTrap(
      Map<String, PuzzleNode> nodes, Map<String, PuzzleEdge> edges,
      String fromId, String toId) {
    final eId = 't_${fromId}_$toId';
    if (edges.containsKey(eId)) return;
    edges[eId] = PuzzleEdge(
      id: eId, fromNodeId: fromId, toNodeId: toId,
      direction: _dir(nodes[fromId]!, nodes[toId]!),
      isSolutionEdge: false,
    );
    nodes[fromId] = nodes[fromId]!.copyWith(
      outgoingEdgeIds: [...nodes[fromId]!.outgoingEdgeIds, eId],
    );
  }

  bool _edgeExists(PuzzleNode node, Map<String, PuzzleEdge> edges, String toId) =>
      node.outgoingEdgeIds.any((eid) => edges[eid]?.toNodeId == toId);

  List<String> _rawNbrs(PuzzleNode n, Map<String, PuzzleNode> nodes) => [
    if (nodes.containsKey('n${n.gridX}_${n.gridY - 1}')) 'n${n.gridX}_${n.gridY - 1}',
    if (nodes.containsKey('n${n.gridX}_${n.gridY + 1}')) 'n${n.gridX}_${n.gridY + 1}',
    if (nodes.containsKey('n${n.gridX - 1}_${n.gridY}')) 'n${n.gridX - 1}_${n.gridY}',
    if (nodes.containsKey('n${n.gridX + 1}_${n.gridY}')) 'n${n.gridX + 1}_${n.gridY}',
  ];

  ArrowDirection _dir(PuzzleNode a, PuzzleNode b) {
    final dx = b.gridX - a.gridX; final dy = b.gridY - a.gridY;
    if (dy < 0) return ArrowDirection.up;
    if (dy > 0) return ArrowDirection.down;
    if (dx < 0) return ArrowDirection.left;
    return ArrowDirection.right;
  }
}
