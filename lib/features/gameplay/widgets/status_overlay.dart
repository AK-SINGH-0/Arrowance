// lib/features/gameplay/widgets/status_overlay.dart
//
// Win overlay: animated star rating + shareable FLEX CARD with copy-to-clipboard.
// Fail overlay: clean error state with retry.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arrowance/game/models/graph_models.dart';
import 'package:arrowance/features/gameplay/theme/game_theme.dart';

class StatusOverlay extends StatefulWidget {
  final bool isWin;
  final String title;
  final String message;
  final VoidCallback onAction;
  final TraversalState? traversal;
  final int? timeElapsed;
  final int? levelNumber;

  const StatusOverlay({
    super.key,
    required this.isWin,
    required this.title,
    required this.message,
    required this.onAction,
    this.traversal,
    this.timeElapsed,
    this.levelNumber,
  });

  @override
  State<StatusOverlay> createState() => _StatusOverlayState();
}

class _StatusOverlayState extends State<StatusOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  bool _showFlexCard = false;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade  = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5)));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  String _elapsedStr(int s) {
    final m  = s ~/ 60;
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  String _buildShareText() {
    final lvl = widget.levelNumber ?? 0;
    final timeStr = _elapsedStr(widget.timeElapsed ?? 0);
    final stars = widget.traversal?.starsForReverts() ?? 1;
    final starStr = '⭐' * stars;
    return '🏆 I solved Arrowance Level $lvl in $timeStr! $starStr\n'
        'Can you beat my time? 🔥 #Arrowance #PuzzleGame';
  }

  void _copyShare() async {
    await Clipboard.setData(ClipboardData(text: _buildShareText()));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: FadeTransition(
          opacity: _fade,
          child: Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: Center(
              child: ScaleTransition(
                scale: _scale,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: widget.isWin ? _buildWin() : _buildFail(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Win card ─────────────────────────────────────────────────────────────
  Widget _buildWin() {
    final tr      = widget.traversal;
    final stars   = tr?.starsForReverts() ?? 1;
    final combo   = tr?.maxCombo ?? 0;
    final elapsed = widget.timeElapsed ?? 0;
    final lvl     = widget.levelNumber ?? 0;

    return Container(
      decoration: BoxDecoration(
        gradient: GameTheme.cardGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: GameTheme.nodeStart.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: GameTheme.nodeStart.withValues(alpha: 0.25),
            blurRadius: 40, spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [GameTheme.nodeStart.withValues(alpha: 0.18), Colors.transparent],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 52, color: GameTheme.nodeStart),
                const SizedBox(height: 10),
                Text(widget.title,
                    style: GameTheme.titleStyle.copyWith(
                      fontSize: 24, color: Colors.white,
                      shadows: [Shadow(color: GameTheme.nodeStart.withValues(alpha: 0.6), blurRadius: 12)],
                    )),
                const SizedBox(height: 4),
                Text(widget.message, style: GameTheme.subtitleStyle,
                    textAlign: TextAlign.center),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              children: [
                // Stars
                _StarRow(stars: stars),
                const SizedBox(height: 6),
                Text(_starLabel(stars),
                    style: GameTheme.titleStyle.copyWith(
                      fontSize: 14,
                      color: _starColor(stars),
                    )),

                const SizedBox(height: 16),

                // Stats row
                _StatsRow(
                  elapsed: elapsed,
                  level: lvl,
                  moves: tr?.visitedCount ?? 0,
                  combo: combo,
                ),

                const SizedBox(height: 16),

                // Flex card toggle
                GestureDetector(
                  onTap: () => setState(() => _showFlexCard = !_showFlexCard),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B2FBE), Color(0xFF40C4FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: GameTheme.pathColor.withValues(alpha: 0.35),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.share_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Flex & Share',
                            style: GameTheme.titleStyle.copyWith(
                              fontSize: 14, color: Colors.white)),
                      ],
                    ),
                  ),
                ),

                // Flex card
                if (_showFlexCard) ...[
                  const SizedBox(height: 12),
                  _FlexCard(
                    level: lvl,
                    elapsed: elapsed,
                    stars: stars,
                    combo: combo,
                    onCopy: _copyShare,
                    copied: _copied,
                  ),
                ],

                const SizedBox(height: 16),

                // Next level button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: const Text('Next Level',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameTheme.nodeStart,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: widget.onAction,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Fail card ─────────────────────────────────────────────────────────────
  Widget _buildFail() {
    return Container(
      decoration: BoxDecoration(
        gradient: GameTheme.cardGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: GameTheme.nodeEnd.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: GameTheme.nodeEnd.withValues(alpha: 0.20),
            blurRadius: 40, spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.heart_broken_rounded, size: 56, color: GameTheme.nodeEnd,
                shadows: [Shadow(color: GameTheme.nodeEnd.withValues(alpha: 0.6), blurRadius: 14)]),
            const SizedBox(height: 14),
            Text(widget.title,
                style: GameTheme.titleStyle.copyWith(fontSize: 22)),
            const SizedBox(height: 6),
            Text(widget.message, style: GameTheme.subtitleStyle,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Try Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTheme.nodeEnd,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: widget.onAction,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _starLabel(int s) => ['⭐ Complete', '⭐⭐ Great!', '⭐⭐⭐ Perfect!'][s - 1];
  Color _starColor(int s) => [GameTheme.textMuted, GameTheme.pathColor, GameTheme.neonGold][s - 1];
}

// ── Star row ──────────────────────────────────────────────────────────────────
class _StarRow extends StatelessWidget {
  final int stars;
  const _StarRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final lit = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 200 + i * 120),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              lit ? Icons.star_rounded : Icons.star_outline_rounded,
              key: ValueKey(lit),
              size: 40,
              color: lit ? GameTheme.neonGold : Colors.white12,
              shadows: lit ? [Shadow(color: GameTheme.neonGold.withValues(alpha: 0.5), blurRadius: 12)] : null,
            ),
          ),
        );
      }),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int elapsed, level, moves, combo;
  const _StatsRow({
    required this.elapsed, required this.level,
    required this.moves, required this.combo,
  });

  String _fmt(int s) {
    final m  = s ~/ 60;
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(icon: Icons.timer_rounded, label: 'Time', value: _fmt(elapsed), color: GameTheme.neonGold),
        _divider(),
        _Stat(icon: Icons.layers_rounded, label: 'Level', value: '$level', color: GameTheme.pathColor),
        _divider(),
        _Stat(icon: Icons.local_fire_department_rounded,
            label: 'Combo', value: '×$combo', color: GameTheme.neonOrange),
      ],
    );
  }

  Widget _divider() => Container(
    height: 36, width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: GameTheme.surfaceBorder,
  );
}

class _Stat extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _Stat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 3),
        Text(value, style: GameTheme.monoStyle.copyWith(color: color, fontSize: 15)),
        Text(label, style: GameTheme.labelStyle),
      ],
    ),
  );
}

// ── Flex card (shareable) ─────────────────────────────────────────────────────
class _FlexCard extends StatelessWidget {
  final int level, elapsed, stars, combo;
  final VoidCallback onCopy;
  final bool copied;

  const _FlexCard({
    required this.level, required this.elapsed,
    required this.stars, required this.combo,
    required this.onCopy, required this.copied,
  });

  String _fmt(int s) {
    final m  = s ~/ 60;
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final starStr = '⭐' * stars;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1A1040), Color(0xFF0F1830)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GameTheme.neonPurple.withValues(alpha: 0.5), width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GameTheme.neonPurple.withValues(alpha: 0.20), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App brand
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B2FBE), GameTheme.pathColor]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('ARROWANCE',
                    style: GameTheme.labelStyle.copyWith(
                      color: Colors.white, letterSpacing: 2.0, fontSize: 10)),
              ),
              const Spacer(),
              Text('arrowance.app',
                  style: GameTheme.labelStyle.copyWith(fontSize: 9)),
            ],
          ),
          const SizedBox(height: 14),

          // Main flex line
          RichText(
            text: TextSpan(
              style: GameTheme.titleStyle.copyWith(height: 1.4),
              children: [
                TextSpan(text: '🏆 Solved Level '),
                TextSpan(
                  text: '$level',
                  style: TextStyle(
                    color: GameTheme.neonGold,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(color: GameTheme.neonGold.withValues(alpha: 0.6), blurRadius: 10)],
                  ),
                ),
                TextSpan(text: ' in\n'),
                TextSpan(
                  text: _fmt(elapsed),
                  style: TextStyle(
                    color: GameTheme.nodeStart,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(color: GameTheme.nodeStart.withValues(alpha: 0.7), blurRadius: 12)],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Stars + combo
          Row(
            children: [
              Text(starStr, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              if (combo >= 3)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: GameTheme.neonOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: GameTheme.neonOrange.withValues(alpha: 0.4)),
                  ),
                  child: Text('🔥 Combo ×$combo',
                      style: TextStyle(
                        color: GameTheme.neonOrange,
                        fontSize: 12, fontWeight: FontWeight.bold,
                      )),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text('Can you beat my time? #Arrowance',
              style: GameTheme.subtitleStyle.copyWith(fontSize: 11)),

          const SizedBox(height: 14),

          // Copy button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(
                copied ? Icons.check_rounded : Icons.copy_rounded, size: 17),
              label: Text(
                copied ? 'Copied!' : 'Copy to Share',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: copied
                    ? GameTheme.nodeStart.withValues(alpha: 0.85)
                    : GameTheme.neonPurple.withValues(alpha: 0.7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: onCopy,
            ),
          ),
        ],
      ),
    );
  }
}
