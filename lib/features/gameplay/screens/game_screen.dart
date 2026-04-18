// lib/features/gameplay/screens/game_screen.dart
//
// FULL-SCREEN BOARD LAYOUT
// - Top bar:    52px fixed
// - Banner:     animated, ~36px
// - Board:      Expanded (fills everything left)
// - Footer:     64px fixed
// Total non-board: ~152px on a 750px phone = board takes ~80% of height

import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:arrowance/game/state/game_providers.dart';
import 'package:arrowance/game/models/graph_models.dart';
import 'package:arrowance/features/gameplay/theme/game_theme.dart';
import 'package:arrowance/features/gameplay/widgets/top_bar.dart';
import 'package:arrowance/features/gameplay/widgets/game_board.dart';
import 'package:arrowance/features/gameplay/widgets/bottom_controls.dart';
import 'package:arrowance/features/gameplay/widgets/status_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});
  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late int _level;
  late int _seed;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final progress = ref.read(hiveServiceProvider).loadProgress();
      _level = progress.currentLevel;
      _seed  = 42 + _level * 37;
      _loadLevel();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _loadLevel() =>
      ref.read(gameStateProvider.notifier).loadLevel(_level, _seed);

  void _nextLevel() {
    setState(() { _level++; _seed = 42 + _level * 37; });
    _loadLevel();
  }

  void _replay() => ref.read(gameStateProvider.notifier).resetTraversal();

  String _failMsg(FailReason? r) => switch (r) {
    FailReason.livesOut => 'Undos exhausted — study the grid!',
    FailReason.timeOut  => 'Time ran out — think faster!',
    null                => 'Something went wrong.',
  };

  @override
  Widget build(BuildContext context) {
    final status    = ref.watch(gameStatusProvider);
    final failR     = ref.watch(gameStateProvider.select((s) => s.traversal.failReason));
    final traversal = ref.watch(gameStateProvider.select((s) => s.traversal));
    final gs        = ref.watch(gameStateProvider);

    ref.listen(gameStatusProvider, (_, next) {
      if (next == GameStatus.won) _confetti.play();
    });

    return Scaffold(
      backgroundColor: Colors.black, // fallback
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Beautiful Wallpaper Background ───────────────────────────
          Image.asset(
            'assets/images/wallpaper.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: const BoxDecoration(gradient: GameTheme.bgGradient),
            ),
          ),

          
          // ── Foreground UI ─────────────────────────────────────────
          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // ── Compact top bar (52px) ──────────────────────────
                    const GameTopBar(),

                    // ── Board — takes ALL remaining space ───────────────
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 6),
                            child: const GameBoard(),
                          ),
                          // ── Floating animated banner (Centered) ──────────
                          Positioned(
                            top: 6, // Floats slightly above the board
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) => FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, -0.5),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: child,
                                ),
                              ),
                              child: _banner(gs, traversal),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Compact footer (64px) ───────────────────────────
                    BottomControls(onReset: _replay),
                  ],
                ),


              // ── Overlays ────────────────────────────────────────────
              if (status == GameStatus.won)
                StatusOverlay(
                  isWin: true,
                  title: 'Level Cleared! 🎉',
                  message: 'You found the only valid path.',
                  onAction: _nextLevel,
                  traversal: traversal,
                  timeElapsed: gs.timeElapsed,
                  levelNumber: gs.levelNumber,
                ),

              if (status == GameStatus.failed)
                StatusOverlay(
                  isWin: false,
                  title: 'Out of Moves',
                  message: _failMsg(failR),
                  onAction: _replay,
                ),

              // ── Confetti ────────────────────────────────────────────
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 14,
                  minBlastForce: 6,
                  emissionFrequency: 0.05,
                  numberOfParticles: 30,
                  gravity: 0.22,
                  colors: const [
                    Color(0xFF16A34A), Color(0xFFDC2626),
                    Color(0xFF4F46E5), Color(0xFFD97706), Color(0xFF9333EA),
                  ],
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }


  Widget _banner(GameState gs, traversal) {
    final status  = gs.status;
    final isStuck = traversal.isStuck;
    final combo   = traversal.combo;

    if (status == GameStatus.idle) {
      return _Banner(
        key: const ValueKey('idle'),
        icon: Icons.touch_app_rounded,
        text: 'Tap  S  to start',
        color: const Color(0xFF16A34A),
      );
    }
    if (isStuck) {
      return _Banner(
        key: const ValueKey('stuck'),
        icon: Icons.warning_amber_rounded,
        text: 'Dead end — press Undo',
        color: const Color(0xFFDC2626),
        glow: true,
      );
    }
    if (combo >= 4) {
      return _Banner(
        key: ValueKey('combo-$combo'),
        icon: Icons.local_fire_department_rounded,
        text: 'Combo ×$combo  🔥',
        color: GameTheme.neonOrange,
        glow: true,
      );
    }
    if (status == GameStatus.playing) {
      return _Banner(
        key: const ValueKey('playing'),
        icon: Icons.psychology_rounded,
        text: 'All arrows look the same — reason it out',
        color: GameTheme.textMuted,
      );
    }
    return const SizedBox.shrink(key: ValueKey('none'));
  }
}

// ── Slim banner ───────────────────────────────────────────────────────────────
class _Banner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool glow;

  const _Banner({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: dart_ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
            boxShadow: glow
                ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 16)]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 8),
              Text(text,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [Shadow(color: color.withValues(alpha: 0.8), blurRadius: 4)])),
            ],
          ),
        ),
      ),
    );
  }
}
