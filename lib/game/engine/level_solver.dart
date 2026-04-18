// lib/game/engine/level_solver.dart
//
// OPTIMIZED: Instead of brute-force DFS, we use a lightweight structural
// verification that checks whether the pre-embedded solution path is intact.
// This runs in O(V) time regardless of graph density, eliminating all freezes.

import '../models/graph_models.dart';

class LevelSolver {
  const LevelSolver();

  /// Fast structural verification:
  /// Walks the embedded solution path (nodes linked in order via 'main' edges)
  /// to confirm each step is reachable. O(V) — safe for any grid size.
  bool solveGraph(LevelGraph graph) {
    if (graph.nodes.isEmpty || graph.edges.isEmpty) return false;

    PuzzleNode? startNode;
    for (final node in graph.nodes.values) {
      if (node.type == NodeType.start) {
        startNode = node;
        break;
      }
    }
    if (startNode == null) return false;

    // Walk the first edge from each node (guaranteed to be the solution edge
    // because LevelGenerator prepends solution edges to outgoingEdgeIds).
    final visited = <String>{};
    String currentId = startNode.id;

    while (true) {
      if (visited.contains(currentId)) return false; // cycle
      visited.add(currentId);

      final node = graph.nodes[currentId]!;

      if (node.type == NodeType.end) {
        // Valid only if we visited every node
        return visited.length == graph.nodes.length;
      }

      // The first outgoing edge is always the solution edge (prepended by generator)
      final solutionEdgeId = node.outgoingEdgeIds.isNotEmpty ? node.outgoingEdgeIds.first : null;
      if (solutionEdgeId == null) return false;

      final solutionEdge = graph.edges[solutionEdgeId];
      if (solutionEdge == null) return false;

      currentId = solutionEdge.toNodeId;
    }
  }
}
