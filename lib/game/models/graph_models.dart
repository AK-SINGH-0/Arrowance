// lib/game/models/graph_models.dart

enum ArrowDirection {
  up, down, left, right;

  (int, int) get delta => switch (this) {
    ArrowDirection.up    => (0, -1),
    ArrowDirection.down  => (0,  1),
    ArrowDirection.left  => (-1, 0),
    ArrowDirection.right => (1,  0),
  };
  int get dx => delta.$1;
  int get dy => delta.$2;

  ArrowDirection get opposite => switch (this) {
    ArrowDirection.up    => ArrowDirection.down,
    ArrowDirection.down  => ArrowDirection.up,
    ArrowDirection.left  => ArrowDirection.right,
    ArrowDirection.right => ArrowDirection.left,
  };
}

enum NodeType { start, normal, end }

// ─────────────────────────────────────────────────────────────
class PuzzleNode {
  final String id;
  final int gridX;
  final int gridY;
  final NodeType type;
  final List<String> outgoingEdgeIds;

  const PuzzleNode({
    required this.id,
    required this.gridX,
    required this.gridY,
    this.type = NodeType.normal,
    this.outgoingEdgeIds = const [],
  });

  PuzzleNode copyWith({
    String? id, int? gridX, int? gridY,
    NodeType? type, List<String>? outgoingEdgeIds,
  }) => PuzzleNode(
    id: id ?? this.id,
    gridX: gridX ?? this.gridX,
    gridY: gridY ?? this.gridY,
    type: type ?? this.type,
    outgoingEdgeIds: outgoingEdgeIds ?? this.outgoingEdgeIds,
  );
}

class PuzzleEdge {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final ArrowDirection direction;
  final bool isSolutionEdge; // used only by solver, hidden from player

  const PuzzleEdge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.direction,
    this.isSolutionEdge = false,
  });
}

class LevelGraph {
  final int levelNumber;
  final int gridCols;
  final int gridRows;
  final int seed;
  final Map<String, PuzzleNode> nodes;
  final Map<String, PuzzleEdge> edges;

  const LevelGraph({
    required this.levelNumber,
    required this.gridCols,
    required this.gridRows,
    required this.seed,
    required this.nodes,
    required this.edges,
  });

  PuzzleNode get startNode => nodes.values.firstWhere((n) => n.type == NodeType.start);
}

// ─────────────────────────────────────────────────────────────
enum GameStatus { idle, playing, won, failed }

enum FailReason { livesOut, timeOut }

const int kMaxLives = 3;

class TraversalState {
  final String? currentNodeId;
  final List<String> pathTaken;       // edge IDs in order
  final Set<String> visitedNodeIds;
  final bool isTraversing;
  final FailReason? failReason;
  final int lives;                    // remaining hearts (0-3)
  final int revertsUsed;              // how many undos used (→ star rating)
  final int combo;                    // consecutive forward steps without revert
  final int maxCombo;                 // session high
  final String? hintNodeId;           // briefly shown next-correct node
  final bool isStuck;                 // no valid moves, player must revert

  const TraversalState({
    this.currentNodeId,
    this.pathTaken    = const [],
    this.visitedNodeIds = const {},
    this.isTraversing = false,
    this.failReason,
    this.lives        = kMaxLives,
    this.revertsUsed  = 0,
    this.combo        = 0,
    this.maxCombo     = 0,
    this.hintNodeId,
    this.isStuck      = false,
  });

  int get visitedCount => visitedNodeIds.length;
  bool hasVisited(String id) => visitedNodeIds.contains(id);

  /// Stars: 3=no reverts, 2=1-2 reverts, 1=3 reverts, 0=fail
  int starsForReverts() {
    if (revertsUsed == 0) return 3;
    if (revertsUsed <= 2) return 2;
    return 1;
  }

  TraversalState copyWith({
    String? currentNodeId,
    List<String>? pathTaken,
    Set<String>? visitedNodeIds,
    bool? isTraversing,
    FailReason? failReason,
    bool clearFail = false,
    int? lives,
    int? revertsUsed,
    int? combo,
    int? maxCombo,
    String? hintNodeId,
    bool clearHint = false,
    bool? isStuck,
  }) => TraversalState(
    currentNodeId: currentNodeId ?? this.currentNodeId,
    pathTaken:     pathTaken     ?? this.pathTaken,
    visitedNodeIds: visitedNodeIds ?? this.visitedNodeIds,
    isTraversing:  isTraversing  ?? this.isTraversing,
    failReason:    clearFail ? null : (failReason ?? this.failReason),
    lives:         lives         ?? this.lives,
    revertsUsed:   revertsUsed   ?? this.revertsUsed,
    combo:         combo         ?? this.combo,
    maxCombo:      maxCombo      ?? this.maxCombo,
    hintNodeId:    clearHint ? null : (hintNodeId ?? this.hintNodeId),
    isStuck:       isStuck       ?? this.isStuck,
  );
}

class GameState {
  final LevelGraph graph;
  final TraversalState traversal;
  final GameStatus status;
  final int movesUsed;
  final int timeElapsed;   // ← counting UP (seconds since start)
  final int maxTime;       // ← hard limit; fail if elapsed > maxTime

  const GameState({
    required this.graph,
    this.traversal     = const TraversalState(),
    this.status        = GameStatus.idle,
    this.movesUsed     = 0,
    this.timeElapsed   = 0,
    this.maxTime       = 90,
  });

  int get levelNumber => graph.levelNumber;
  int get lives       => traversal.lives;

  /// Remaining seconds the player still has (shown only as a limit).
  int get timeRemaining => (maxTime - timeElapsed).clamp(0, maxTime);

  /// Human-readable elapsed time string  e.g. "1:04"
  String get elapsedStr {
    final m = (timeElapsed ~/ 60);
    final s = (timeElapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  GameState copyWith({
    LevelGraph? graph,
    TraversalState? traversal,
    GameStatus? status,
    int? movesUsed,
    int? timeElapsed,
    int? maxTime,
  }) => GameState(
    graph:       graph       ?? this.graph,
    traversal:   traversal   ?? this.traversal,
    status:      status      ?? this.status,
    movesUsed:   movesUsed   ?? this.movesUsed,
    timeElapsed: timeElapsed ?? this.timeElapsed,
    maxTime:     maxTime     ?? this.maxTime,
  );
}
