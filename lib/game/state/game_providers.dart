// lib/game/state/game_providers.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/graph_models.dart';
import '../engine/game_engine.dart';
import '../engine/difficulty.dart';
import '../engine/level_generator.dart';
import '../engine/level_solver.dart';
import '../../data/storage/hive_service.dart';

class GameStateNotifier extends StateNotifier<GameState> {
  final GameEngine      _engine;
  final LevelGenerator  _generator;
  final HiveService     _hiveService;
  Timer? _timer;
  Timer? _hintClearTimer;

  GameStateNotifier({
    required GameEngine engine,
    required LevelGenerator generator,
    required HiveService hiveService,
    required GameState initialState,
  })  : _engine = engine,
        _generator = generator,
        _hiveService = hiveService,
        super(initialState);

  @override
  void dispose() {
    _timer?.cancel();
    _hintClearTimer?.cancel();
    super.dispose();
  }

  // ── Load level ────────────────────────────────────────────────────────
  void loadLevel(int levelNumber, int seed) {
    _timer?.cancel();
    _hintClearTimer?.cancel();
    final config = DifficultyConfig.forLevel(levelNumber);
    final graph  = _generator.generateLevel(
        levelNumber: levelNumber, seed: seed, config: config);
    state = GameState(
      graph: graph,
      traversal: const TraversalState(),
      status: GameStatus.idle,
      movesUsed: 0,
      timeElapsed: 0,          // count-up starts at 0
      maxTime: config.timeSeconds,
    );
  }

  // ── Start traversal ──────────────────────────────────────────────────
  void startTraversal() {
    if (state.status != GameStatus.idle) return;
    final result = _engine.startTraversal(state.graph, state.graph.startNode.id);
    state = state.copyWith(traversal: result.traversal, status: result.status);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.status != GameStatus.playing) { t.cancel(); return; }
      final elapsed = state.timeElapsed + 1;
      if (elapsed >= state.maxTime) {
        // Time's up → fail
        t.cancel();
        state = state.copyWith(
          timeElapsed: elapsed,
          status: GameStatus.failed,
          traversal: state.traversal.copyWith(
              failReason: FailReason.timeOut, isTraversing: false),
        );
      } else {
        state = state.copyWith(timeElapsed: elapsed);
      }
    });
  }

  // ── Forward move ──────────────────────────────────────────────────────
  void moveTo(String targetNodeId) {
    if (state.status != GameStatus.playing) return;
    final result = _engine.stepTraversal(state.graph, state.traversal, targetNodeId);
    state = state.copyWith(
      traversal: result.traversal,
      status: result.status,
      movesUsed: state.movesUsed + 1,
    );
    if (result.status == GameStatus.won) {
      _timer?.cancel();
      _saveProgress();
    } else if (result.status == GameStatus.failed) {
      _timer?.cancel();
    }
  }

  // ── Revert (undo) ─────────────────────────────────────────────────────
  void revertStep() {
    if (state.status != GameStatus.playing) return;
    final result = _engine.revertStep(state.graph, state.traversal);
    state = state.copyWith(traversal: result.traversal, status: result.status);
    if (result.status == GameStatus.failed) _timer?.cancel();
  }

  // ── Hint ─────────────────────────────────────────────────────────────
  void useHint() {
    if (state.status != GameStatus.playing) return;
    final result = _engine.hint(state.graph, state.traversal);
    state = state.copyWith(traversal: result.traversal, status: result.status);
    if (result.status == GameStatus.failed) { _timer?.cancel(); return; }
    _hintClearTimer?.cancel();
    _hintClearTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        state = state.copyWith(
          traversal: state.traversal.copyWith(clearHint: true));
      }
    });
  }

  // ── Reset current level ────────────────────────────────────────────────
  void resetTraversal() {
    _timer?.cancel();
    _hintClearTimer?.cancel();
    state = state.copyWith(
      traversal: const TraversalState(),
      status: GameStatus.idle,
      movesUsed: 0,
      timeElapsed: 0,
    );
  }

  // ── Save progress on win ──────────────────────────────────────────────
  void _saveProgress() {
    final progress = _hiveService.loadProgress();
    final seeds    = Set<int>.from(progress.completedSeeds)..add(state.graph.seed);
    final next     = state.levelNumber + 1;
    _hiveService.saveProgress(progress.copyWith(
      currentLevel: next,
      highestUnlockedLevel:
          next > progress.highestUnlockedLevel ? next : progress.highestUnlockedLevel,
      completedSeeds: seeds.toList(),
    ));
  }
}

// ─────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────

final hiveServiceProvider =
    Provider<HiveService>((ref) => throw UnimplementedError());

final gameEngineProvider    = Provider((ref) => const GameEngine());
final levelSolverProvider   = Provider((ref) => const LevelSolver());
final levelGeneratorProvider =
    Provider((ref) => LevelGenerator(ref.watch(levelSolverProvider)));

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier(
    engine: ref.watch(gameEngineProvider),
    generator: ref.watch(levelGeneratorProvider),
    hiveService: ref.watch(hiveServiceProvider),
    initialState: const GameState(
      graph: LevelGraph(
          levelNumber: 1, gridCols: 0, gridRows: 0,
          seed: 0, nodes: {}, edges: {}),
    ),
  );
});

final gameStatusProvider   = Provider((ref) => ref.watch(gameStateProvider).status);
final traversalProvider    = Provider((ref) => ref.watch(gameStateProvider).traversal);
final currentGraphProvider = Provider((ref) => ref.watch(gameStateProvider).graph);
final validMovesProvider   = Provider<List<String>>((ref) {
  final engine = ref.watch(gameEngineProvider);
  final s      = ref.watch(gameStateProvider);
  if (s.status != GameStatus.playing) return [];
  return engine.getValidMoves(s.graph, s.traversal);
});
