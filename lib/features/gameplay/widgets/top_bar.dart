// lib/features/gameplay/widgets/top_bar.dart
//
// COMPACT single-row top bar — minimal vertical footprint so the board
// takes up the maximum screen real estate.
// Layout: [LVL N] [⏱ 0:42] [❤❤❤] ──timer bar── [⚙]

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrowance/game/state/game_providers.dart';
import 'package:arrowance/game/models/graph_models.dart';
import 'package:arrowance/features/gameplay/theme/game_theme.dart';
import 'package:arrowance/features/settings/settings_screen.dart';

class GameTopBar extends ConsumerWidget {
  const GameTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(gameStateProvider);
    final elapsed  = state.timeElapsed;
    final remaining = state.timeRemaining;
    final maxT     = state.maxTime;
    final isRunning = state.status == GameStatus.playing;
    final isLow    = remaining <= 15 && isRunning;
    final lives    = state.lives;
    final pct      = maxT > 0 ? remaining / maxT : 1.0;
    final visited  = state.traversal.visitedCount;
    final total    = state.graph.nodes.length;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: GameTheme.surface,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Level pill
          _Pill(
            child: Text(' LVL ${state.levelNumber} ',
              style: GameTheme.monoStyle.copyWith(
                fontSize: 12, color: GameTheme.pathColor)),
          ),
          const SizedBox(width: 6),

          // Timer — count-up  ⏱
          _Pill(
            highlight: isLow,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.speed_rounded, size: 12,
                  color: isLow ? GameTheme.nodeEnd : GameTheme.neonGold),
              const SizedBox(width: 3),
              Text(_fmt(elapsed),
                style: GameTheme.monoStyle.copyWith(
                  fontSize: 12,
                  color: isLow ? GameTheme.nodeEnd : GameTheme.neonGold,
                )),
            ]),
          ),
          const SizedBox(width: 6),

          // Node counter
          _Pill(
            child: Text('$visited/$total',
              style: GameTheme.monoStyle.copyWith(
                fontSize: 12, color: GameTheme.neonPurple)),
          ),

          const SizedBox(width: 8),

          // Time limit bar (flexible, fills remaining space)
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(2),
                  )),
                FractionallySizedBox(
                  widthFactor: pct.clamp(0.0, 1.0),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: isLow
                            ? [GameTheme.nodeEnd, GameTheme.neonOrange]
                            : [GameTheme.neonCyan, GameTheme.pathColor],
                      ),
                      boxShadow: [BoxShadow(
                        color: (isLow ? GameTheme.nodeEnd : GameTheme.neonCyan)
                            .withValues(alpha: 0.55),
                        blurRadius: 5,
                      )],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Hearts
          ...List.generate(kMaxLives, (i) {
            final filled = i < lives;
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  filled ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  key: ValueKey('h$i-$filled'),
                  size: 18,
                  color: filled ? GameTheme.nodeEnd : Colors.white.withValues(alpha: 0.18),
                  shadows: filled
                      ? [Shadow(color: GameTheme.nodeEnd.withValues(alpha: 0.6), blurRadius: 7)]
                      : null,
                ),
              ),
            );
          }),

          const SizedBox(width: 6),

          // Settings
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen())),
            child: Icon(Icons.tune_rounded, size: 20, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

class _Pill extends StatelessWidget {
  final Widget child;
  final bool highlight;
  const _Pill({required this.child, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? GameTheme.nodeEnd.withValues(alpha: 0.12)
            : GameTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight
              ? GameTheme.nodeEnd.withValues(alpha: 0.5)
              : GameTheme.surfaceBorder,
        ),
      ),
      child: child,
    );
  }
}
