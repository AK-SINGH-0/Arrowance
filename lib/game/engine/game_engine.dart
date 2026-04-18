// lib/game/engine/game_engine.dart
//
// ENGINE RULES (final):
//
//  • All outgoing edges are traversable — no wrong-move detection.
//  • Player moves freely. If they reach a dead-end (no valid moves),
//    the isStuck flag is raised — they MUST Revert to continue.
//  • Revert costs 1 life. 0 lives → fail.
//  • Win: be at END node AND all nodes visited.
//  • Hint: briefly reveals which edge is the solution (costs 1 life).
//  • Combo resets on Revert; rises on each forward move.

import '../models/graph_models.dart';

class TraversalResult {
  final TraversalState traversal;
  final GameStatus status;
  const TraversalResult(this.traversal, this.status);
}

class GameEngine {
  const GameEngine();

  // ── Start ────────────────────────────────────────────────────────────────
  TraversalResult startTraversal(LevelGraph graph, String startNodeId) {
    final startNode = graph.nodes[startNodeId]!;
    if (startNode.type != NodeType.start) {
      return const TraversalResult(TraversalState(), GameStatus.idle);
    }
    return TraversalResult(
      TraversalState(
        currentNodeId: startNodeId,
        visitedNodeIds: {startNodeId},
        isTraversing: true,
        lives: kMaxLives,
      ),
      GameStatus.playing,
    );
  }

  // ── Valid tappable nodes ─────────────────────────────────────────────────
  // ALL outgoing unvisited neighbours — solution AND traps look identical.
  List<String> getValidMoves(LevelGraph graph, TraversalState state) {
    if (state.currentNodeId == null || !state.isTraversing) return [];
    final node = graph.nodes[state.currentNodeId]!;
    return [
      for (final eId in node.outgoingEdgeIds)
        if (!state.visitedNodeIds.contains(graph.edges[eId]!.toNodeId))
          graph.edges[eId]!.toNodeId
    ];
  }

  // ── Step forward ─────────────────────────────────────────────────────────
  TraversalResult stepTraversal(
      LevelGraph graph, TraversalState state, String targetNodeId) {
    if (!state.isTraversing) {
      return TraversalResult(state, GameStatus.playing);
    }

    // Find edge
    final currentNode = graph.nodes[state.currentNodeId!]!;
    PuzzleEdge? edge;
    for (final eId in currentNode.outgoingEdgeIds) {
      if (graph.edges[eId]?.toNodeId == targetNodeId) {
        edge = graph.edges[eId];
        break;
      }
    }
    if (edge == null) return TraversalResult(state, GameStatus.playing);

    final newVisited = Set<String>.from(state.visitedNodeIds)..add(targetNodeId);
    final newPath    = List<String>.from(state.pathTaken)..add(edge.id);
    final newCombo   = state.combo + 1;
    final newMaxCombo= newCombo > state.maxCombo ? newCombo : state.maxCombo;

    var newState = state.copyWith(
      currentNodeId: targetNodeId,
      visitedNodeIds: newVisited,
      pathTaken: newPath,
      combo: newCombo,
      maxCombo: newMaxCombo,
      clearHint: true,
      isStuck: false,
    );

    final targetNode = graph.nodes[targetNodeId]!;

    // ── Win check ─────────────────────────────────────────────────────────
    if (targetNode.type == NodeType.end) {
      if (newVisited.length == graph.nodes.length) {
        return TraversalResult(
          newState.copyWith(isTraversing: false),
          GameStatus.won,
        );
      }
      // Reached end too early → natural dead-end, must revert
      return TraversalResult(
        newState.copyWith(isStuck: true),
        GameStatus.playing,
      );
    }

    // Check if new position is a dead-end (no unvisited moves)
    final nextMoves = getValidMoves(graph, newState);
    if (nextMoves.isEmpty) {
      return TraversalResult(
        newState.copyWith(isStuck: true),
        GameStatus.playing,
      );
    }

    return TraversalResult(newState, GameStatus.playing);
  }

  // ── Revert (undo) ────────────────────────────────────────────────────────
  // Always costs 1 life. No penalty feedback shown — just the heart drops.
  TraversalResult revertStep(LevelGraph graph, TraversalState state) {
    if (!state.isTraversing) return TraversalResult(state, GameStatus.playing);
    if (state.pathTaken.isEmpty) return TraversalResult(state, GameStatus.playing);

    final newLives   = state.lives - 1;
    final newReverts = state.revertsUsed + 1;

    if (newLives <= 0) {
      return TraversalResult(
        state.copyWith(
          isTraversing: false,
          failReason: FailReason.livesOut,
          lives: 0,
          revertsUsed: newReverts,
        ),
        GameStatus.failed,
      );
    }

    // Undo the last edge
    final newPath   = List<String>.from(state.pathTaken)..removeLast();
    final startId   = _findStartId(graph)!;
    final newVisited = <String>{startId};
    for (final eId in newPath) {
      final e = graph.edges[eId];
      if (e != null) newVisited.add(e.toNodeId);
    }
    final prevNodeId = newPath.isEmpty
        ? startId
        : graph.edges[newPath.last]!.toNodeId;

    return TraversalResult(
      state.copyWith(
        currentNodeId: prevNodeId,
        pathTaken: newPath,
        visitedNodeIds: newVisited,
        lives: newLives,
        revertsUsed: newReverts,
        combo: 0, // combo resets on revert
        clearHint: true,
        isStuck: false,
      ),
      GameStatus.playing,
    );
  }

  // ── Hint ─────────────────────────────────────────────────────────────────
  // Costs 1 life. Reveals the ID of the NEXT correct node for 2 seconds.
  // The solution edge is always first in outgoingEdgeIds (prepended by generator).
  TraversalResult hint(LevelGraph graph, TraversalState state) {
    if (!state.isTraversing || state.currentNodeId == null) {
      return TraversalResult(state, GameStatus.playing);
    }

    final newLives   = state.lives - 1;
    final newReverts = state.revertsUsed + 1; // costs a "mistake"

    if (newLives <= 0) {
      return TraversalResult(
        state.copyWith(
          isTraversing: false,
          failReason: FailReason.livesOut,
          lives: 0,
          revertsUsed: newReverts,
        ),
        GameStatus.failed,
      );
    }

    // Find the solution edge (prepended first in outgoingEdgeIds)
    final node = graph.nodes[state.currentNodeId]!;
    String? hintTarget;
    for (final eId in node.outgoingEdgeIds) {
      final e = graph.edges[eId];
      if (e != null && e.isSolutionEdge && !state.visitedNodeIds.contains(e.toNodeId)) {
        hintTarget = e.toNodeId;
        break;
      }
    }

    return TraversalResult(
      state.copyWith(
        hintNodeId: hintTarget,
        lives: newLives,
        revertsUsed: newReverts,
      ),
      GameStatus.playing,
    );
  }

  String? _findStartId(LevelGraph graph) {
    for (final n in graph.nodes.values) {
      if (n.type == NodeType.start) return n.id;
    }
    return null;
  }
}
