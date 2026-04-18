// lib/features/gameplay/widgets/game_board.dart
//
// WHITE CARD — the puzzle lives on a bright, clean card that floats
// prominently against the dark background. The card takes up ~78% of
// screen height. Rounded corners, soft shadow, minimal padding.

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrowance/game/state/game_providers.dart';
import 'package:arrowance/game/models/graph_models.dart';
import 'maze_painter.dart';

class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({super.key});
  @override
  ConsumerState<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard>
    with TickerProviderStateMixin {
  late AnimationController _moveCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _particleCtrl;
  int _lastMoves = 0;

  @override
  void initState() {
    super.initState();
    _moveCtrl    = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 230))..value = 1.0;
    _pulseCtrl   = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1300))..repeat(reverse: true);
    _particleCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _moveCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  void _onTap(Offset local, Size board) {
    final status = ref.read(gameStatusProvider);
    final graph  = ref.read(currentGraphProvider);
    final nodeId = hitTestNode(local, board, graph, 14.0);
    if (nodeId == null) return;

    if (status == GameStatus.idle) {
      if (graph.nodes[nodeId]?.type == NodeType.start) {
        ref.read(gameStateProvider.notifier).startTraversal();
      }
    } else if (status == GameStatus.playing) {
      final valid = ref.read(validMovesProvider);
      if (valid.contains(nodeId)) {
        ref.read(gameStateProvider.notifier).moveTo(nodeId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state   = ref.watch(gameStateProvider);
    final valid   = ref.watch(validMovesProvider);
    final isStuck = state.traversal.isStuck;

    ref.listen(gameStateProvider, (_, next) {
      if (next.movesUsed > _lastMoves) {
        _lastMoves = next.movesUsed;
        _moveCtrl.forward(from: 0.0);
      }
      if (next.movesUsed < _lastMoves || next.status == GameStatus.idle) {
        _lastMoves = 0;
        _moveCtrl.value = 1.0;
      }
    });

    return LayoutBuilder(builder: (ctx, constraints) {
      final side = math.min(constraints.maxWidth, constraints.maxHeight);

      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: side,
              height: side,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0F2C).withValues(alpha: 0.65), // Deep space blue glass
                border: isStuck
                    ? Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.6), width: 2)
                    : Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                boxShadow: isStuck
                    ? [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                          blurRadius: 28, spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: GestureDetector(
                onTapDown: (d) {
                  _onTap(d.localPosition, Size(side, side));
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedBuilder(
                  animation: Listenable.merge(
                      [_moveCtrl, _pulseCtrl, _particleCtrl]),
                  builder: (context, child) => CustomPaint(
                    painter: MazePainter(
                      graph: state.graph,
                      traversal: state.traversal,
                      status: state.status,
                      validMoves: valid.toSet(),
                      pathAnimationProgress: _moveCtrl.value,
                      pulseProgress: _pulseCtrl.value,
                      particleProgress: _particleCtrl.value,
                    ),
                    size: Size(side, side),
                  ),
                ),
              ),
            ),
          ),
        ),

      );
    });
  }
}
