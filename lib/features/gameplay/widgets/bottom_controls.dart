// lib/features/gameplay/widgets/bottom_controls.dart
//
// COMPACT FOOTER — 3 equal buttons in a slim 64px strip.
// Buttons are icon + small label. Neon accent borders on active state.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrowance/game/state/game_providers.dart';
import 'package:arrowance/game/models/graph_models.dart';
import 'package:arrowance/features/gameplay/theme/game_theme.dart';

class BottomControls extends ConsumerWidget {
  final VoidCallback onReset;
  const BottomControls({super.key, required this.onReset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state     = ref.watch(gameStateProvider);
    final isPlaying = state.status == GameStatus.playing;
    final lives     = state.lives;
    final canRevert = isPlaying && state.traversal.pathTaken.isNotEmpty && lives > 0;
    final canHint   = isPlaying && lives > 0 && !state.traversal.isStuck;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GameTheme.surface,
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, -3)),
        ],
      ),
      child: Row(
        children: [
          _Btn(
            icon: Icons.restart_alt_rounded,
            label: 'Reset',
            accent: GameTheme.textMuted,
            enabled: true,
            onTap: onReset,
          ),
          const SizedBox(width: 8),
          _Btn(
            icon: Icons.undo_rounded,
            label: 'Undo',
            accent: GameTheme.neonPurple,
            enabled: canRevert,
            hasBadge: true,
            onTap: canRevert
                ? () => ref.read(gameStateProvider.notifier).revertStep()
                : null,
          ),
          const SizedBox(width: 8),
          _Btn(
            icon: Icons.lightbulb_rounded,
            label: 'Hint',
            accent: GameTheme.neonGold,
            enabled: canHint,
            hasBadge: true,
            onTap: canHint
                ? () => ref.read(gameStateProvider.notifier).useHint()
                : null,
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final bool enabled;
  final bool hasBadge;
  final VoidCallback? onTap;

  const _Btn({
    required this.icon,
    required this.label,
    required this.accent,
    required this.enabled,
    this.hasBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor  = enabled ? accent : GameTheme.textMuted;
    final activeBg     = enabled && hasBadge
        ? accent.withValues(alpha: 0.09)
        : GameTheme.surfaceHigh;
    final activeBorder = enabled && hasBadge
        ? accent.withValues(alpha: 0.40)
        : GameTheme.surfaceBorder;

    return Expanded(
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.38,
        duration: const Duration(milliseconds: 200),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                splashColor: activeColor.withValues(alpha: 0.15),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: activeBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: activeBorder, width: 1.2),
                    boxShadow: enabled && hasBadge
                        ? [BoxShadow(
                            color: accent.withValues(alpha: 0.18),
                            blurRadius: 10)]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20,
                          color: activeColor,
                          shadows: enabled && hasBadge
                              ? [Shadow(color: accent.withValues(alpha: 0.5), blurRadius: 6)]
                              : null),
                      const SizedBox(width: 5),
                      Text(label,
                          style: GameTheme.titleStyle.copyWith(
                            fontSize: 13,
                            color: enabled
                                ? Colors.white.withValues(alpha: 0.88)
                                : GameTheme.textMuted,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            // ❤ cost badge
            if (hasBadge && enabled)
              Positioned(
                top: -8, right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: GameTheme.nodeEnd,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GameTheme.surface, width: 1.4),
                    boxShadow: [BoxShadow(
                      color: GameTheme.nodeEnd.withValues(alpha: 0.45),
                      blurRadius: 7)],
                  ),
                  child: const Text('❤',
                    style: TextStyle(fontSize: 9, color: Colors.white,
                        fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
