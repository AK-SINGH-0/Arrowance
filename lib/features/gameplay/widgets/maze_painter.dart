// lib/features/gameplay/widgets/maze_painter.dart
//
// LIGHT-THEME PUZZLE BOARD
//
// The card is white/cream — clean paper-like surface.
// All game logic colours map to a light-background palette.
// Neon glow trail and particles still work because they're drawn on top.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:arrowance/game/models/graph_models.dart';

// ── Light-board colour palette ────────────────────────────────────────────────
class _BoardPalette {
  static const bgGrid     = Color(0xFF1E293B);   // dark slate grid dots

  // Edges (unvisited — all look identical, neutral)
  static const edgeLine   = Color(0xFF334155);   // slate
  static const edgeArrow  = Color(0xFF475569);

  // Solution trail
  static const trail      = Color(0xFF00E5FF);   // neon cyan
  static const trailGlow  = Color(0xFF84FFFF);

  // Node variants
  static const nodeDefault = Color(0xFF1E293B);  // dark unvisited
  static const nodeBorder  = Color(0xFF334155);  // border
  static const nodeVisited = Color(0xFFCE93D8);  // neon purple
  static const nodeStart   = Color(0xFF00E676);  // neon green
  static const nodeEnd     = Color(0xFFFF1744);  // neon red
  static const nodeCurrent = Color(0xFF00E5FF);  // neon cyan
  static const nodeHint    = Color(0xFFFFD600);  // vivid gold

}

class MazePainter extends CustomPainter {
  final LevelGraph graph;
  final TraversalState traversal;
  final GameStatus status;
  final Set<String> validMoves;
  final double pathAnimationProgress;
  final double pulseProgress;
  final double particleProgress;

  MazePainter({
    required this.graph,
    required this.traversal,
    required this.status,
    required this.validMoves,
    this.pathAnimationProgress = 1.0,
    this.pulseProgress = 0.0,
    this.particleProgress = 0.0,
  });

  double _cell(Size size) {
    if (graph.gridCols == 0 || graph.gridRows == 0) return 0;
    return math.min(size.width / graph.gridCols,
                    size.height / graph.gridRows);
  }

  Offset _pos(int gx, int gy, Size size) {
    final c  = _cell(size);
    final ox = (size.width  - c * graph.gridCols) / 2;
    final oy = (size.height - c * graph.gridRows) / 2;
    return Offset(ox + gx * c + c / 2, oy + gy * c + c / 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (graph.nodes.isEmpty) return;
    final c = _cell(size);
    if (c == 0) return;

    // Node sizing — generous for touch, clear visibility
    final nr   = c * 0.23;          // node radius
    final gap  = nr + c * 0.07;     // line-to-node gap
    final lw   = c * 0.025;         // base line width

    // ── Subtle dot grid (paper feel) ─────────────────────────────────────
    _drawDotGrid(canvas, size, c);

    // ── Stuck vignette (light red wash) ──────────────────────────────────
    if (traversal.isStuck) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFFDC2626).withValues(alpha: 0.06),
      );
    }

    // ── Layer 1: edge glow coat (traversed only) ──────────────────────────
    for (final edge in graph.edges.values) {
      if (!traversal.pathTaken.contains(edge.id)) continue;
      final from = graph.nodes[edge.fromNodeId]; final to = graph.nodes[edge.toNodeId];
      if (from == null || to == null) continue;
      final p1 = _pos(from.gridX, from.gridY, size);
      final p2 = _pos(to.gridX,   to.gridY,   size);
      final dx = edge.direction.dx.toDouble();
      final dy = edge.direction.dy.toDouble();
      canvas.drawLine(
        Offset(p1.dx + dx * gap, p1.dy + dy * gap),
        Offset(p2.dx - dx * gap, p2.dy - dy * gap),
        Paint()
          ..color = _BoardPalette.trailGlow.withValues(alpha: 0.60)
          ..strokeWidth = lw * 7
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),

      );
    }

    // ── Layer 2: all edges ────────────────────────────────────────────────
    for (final edge in graph.edges.values) {
      final from = graph.nodes[edge.fromNodeId]; final to = graph.nodes[edge.toNodeId];
      if (from == null || to == null) continue;
      final p1 = _pos(from.gridX, from.gridY, size);
      final p2 = _pos(to.gridX,   to.gridY,   size);
      final dx = edge.direction.dx.toDouble();
      final dy = edge.direction.dy.toDouble();
      final isTraversed = traversal.pathTaken.contains(edge.id);
      final sp = Offset(p1.dx + dx * gap, p1.dy + dy * gap);
      final ep = Offset(p2.dx - dx * gap, p2.dy - dy * gap);

      canvas.drawLine(sp, ep, Paint()
        ..color = isTraversed ? _BoardPalette.trail : _BoardPalette.edgeLine
        ..strokeWidth = isTraversed ? lw * 2.8 : lw * 1.6
        ..strokeCap = StrokeCap.round);

      // Arrow head
      final t = 0.60;
      final mid = Offset(sp.dx + (ep.dx - sp.dx) * t, sp.dy + (ep.dy - sp.dy) * t);
      _arrow(canvas, mid, edge.direction,
          isTraversed ? _BoardPalette.trail : _BoardPalette.edgeArrow,
          lw * 3.0);
    }

    // ── Layer 3: animated trail (indigo neon on white) ────────────────────
    if (traversal.pathTaken.isNotEmpty) {
      final tp = Paint()
        ..color = _BoardPalette.trail.withValues(alpha: 0.85)
        ..strokeWidth = lw * 2.6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < traversal.pathTaken.length; i++) {
        final edge = graph.edges[traversal.pathTaken[i]]; if (edge == null) continue;
        final from = graph.nodes[edge.fromNodeId]!;
        final to   = graph.nodes[edge.toNodeId]!;
        final p1   = _pos(from.gridX, from.gridY, size);
        final p2   = _pos(to.gridX,   to.gridY,   size);
        final dx   = edge.direction.dx.toDouble();
        final dy   = edge.direction.dy.toDouble();
        final sp   = Offset(p1.dx + dx * nr, p1.dy + dy * nr);
        final rawEp = Offset(p2.dx - dx * nr, p2.dy - dy * nr);
        final ep   = (i == traversal.pathTaken.length - 1 && pathAnimationProgress < 1.0)
            ? Offset(sp.dx + (rawEp.dx - sp.dx) * pathAnimationProgress,
                     sp.dy + (rawEp.dy - sp.dy) * pathAnimationProgress)
            : rawEp;
        canvas.drawLine(sp, ep, tp);
      }
    }

    // ── Layer 4: nodes ────────────────────────────────────────────────────
    for (final node in graph.nodes.values) {
      final center    = _pos(node.gridX, node.gridY, size);
      final isStart   = node.type == NodeType.start;
      final isEnd     = node.type == NodeType.end;
      final isVisited = traversal.hasVisited(node.id);
      final isCurrent = traversal.currentNodeId == node.id;
      final isHint    = traversal.hintNodeId == node.id;

      // Colour
      Color col;
      if (isHint) {
        col = _BoardPalette.nodeHint;
      } else if (isCurrent) {
        col = _BoardPalette.nodeCurrent;
      } else if (isVisited && !isStart) {
        col = _BoardPalette.nodeVisited;
      } else if (isStart) {
        col = _BoardPalette.nodeStart;
      } else if (isEnd) {
        col = _BoardPalette.nodeEnd;
      } else {
        col = _BoardPalette.nodeDefault;
      }

      // Shadow for depth on white background
      canvas.drawCircle(center, nr * 1.15, Paint()
        ..color = const Color(0xFF000000).withValues(alpha: 0.50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));


      // Pulsing outer ring (current node only)
      if (isCurrent) {
        final ringR = nr * (1.2 + pulseProgress * 0.5);
        canvas.drawCircle(center, ringR, Paint()
          ..color = col.withValues(alpha: 0.4 * (1 - pulseProgress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = lw * 1.5);
      }

      // Hint glow
      if (isHint) {
        canvas.drawCircle(center, nr * (1.0 + pulseProgress * 0.5), Paint()
          ..color = _BoardPalette.nodeHint.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      }

      // Node fill with radial gradient sphere effect
      final grad = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 1.0,
        colors: [
          _lighten(col, 0.18),
          col,
          _darken(col, 0.20),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: nr));

      canvas.drawCircle(center, nr, Paint()..shader = grad);

      // Border (gives clear crisp edge on white)
      final borderCol = isVisited || isCurrent || isStart || isEnd || isHint
          ? col.withValues(alpha: 0.0)  // no border on coloured nodes
          : _BoardPalette.nodeBorder;
      if (!isVisited && !isCurrent && !isStart && !isEnd && !isHint) {
        canvas.drawCircle(center, nr, Paint()
          ..color = borderCol
          ..style = PaintingStyle.stroke
          ..strokeWidth = lw * 0.8);
      }

      // Specular highlight (softer on dark nodes)
      canvas.drawArc(
        Rect.fromCircle(
            center: center - Offset(nr * 0.08, nr * 0.12), radius: nr * 0.65),
        -2.3, 1.4, false,
        Paint()
          ..color = Colors.white.withValues(alpha: isVisited || isCurrent ? 0.35 : 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = lw * 1.6,
      );

      // Inner bright centre
      canvas.drawCircle(center, nr * 0.28, Paint()
        ..color = Colors.white.withValues(alpha: isCurrent ? 0.9 : 0.15));


      // S / E label
      if (isStart || isEnd) {
        _drawLabel(canvas, center, isStart ? 'S' : 'E', nr * 1.0, Colors.white);
      }

      // Neon particle sparks on current node
      if (isCurrent) {
        _sparks(canvas, center, nr, col);
      }
    }
  }

  // ── Subtle dot grid ───────────────────────────────────────────────────────
  void _drawDotGrid(Canvas canvas, Size size, double c) {
    final dotPaint = Paint()
      ..color = _BoardPalette.bgGrid
      ..style = PaintingStyle.fill;
    final r = c * 0.025;
    for (int y = 0; y < graph.gridRows; y++) {
      for (int x = 0; x < graph.gridCols; x++) {
        final cx = (size.width - c * graph.gridCols) / 2 + x * c + c / 2;
        final cy = (size.height - c * graph.gridRows) / 2 + y * c + c / 2;
        canvas.drawCircle(Offset(cx, cy), r, dotPaint);
      }
    }
  }

  // ── Neon sparks on current node ───────────────────────────────────────────
  void _sparks(Canvas canvas, Offset center, double nr, Color col) {
    final rng = math.Random(42);
    for (int i = 0; i < 8; i++) {
      final baseAngle = (i / 8) * 2 * math.pi;
      final jitter    = (rng.nextDouble() - 0.5) * 0.7;
      final angle     = baseAngle + jitter + particleProgress * math.pi * 0.5;
      final dist      = nr * (1.25 + rng.nextDouble() * 0.7 + pulseProgress * 0.5);
      final pSize     = nr * (0.05 + rng.nextDouble() * 0.06);
      final alpha     = (0.85 - pulseProgress * 0.65).clamp(0.0, 1.0);
      final pos       = Offset(center.dx + math.cos(angle) * dist,
                               center.dy + math.sin(angle) * dist);

      canvas.drawCircle(pos, pSize * 2.2, Paint()
        ..color = col.withValues(alpha: alpha * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawCircle(pos, pSize, Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.9));
    }
  }

  // ── Arrow head ────────────────────────────────────────────────────────────
  void _arrow(Canvas canvas, Offset pos, ArrowDirection dir, Color col, double sz) {
    final dx = dir.dx.toDouble(); final dy = dir.dy.toDouble();
    final px = -dy; final py = dx;
    final tip   = Offset(pos.dx + dx * sz, pos.dy + dy * sz);
    final left  = Offset(pos.dx - dx * sz * 0.5 + px * sz * 0.5,
                         pos.dy - dy * sz * 0.5 + py * sz * 0.5);
    final right = Offset(pos.dx - dx * sz * 0.5 - px * sz * 0.5,
                         pos.dy - dy * sz * 0.5 - py * sz * 0.5);
    canvas.drawPath(
      Path()..moveTo(tip.dx, tip.dy)..lineTo(left.dx, left.dy)
            ..lineTo(right.dx, right.dy)..close(),
      Paint()..color = col..style = PaintingStyle.fill,
    );
  }

  void _drawLabel(Canvas canvas, Offset c, String text, double fs, Color col) {
    final tp = TextPainter(
      text: TextSpan(text: text,
        style: TextStyle(color: col, fontSize: fs,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)])),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  Color _lighten(Color c, double a) =>
      HSLColor.fromColor(c).withLightness(
          (HSLColor.fromColor(c).lightness + a).clamp(0.0, 1.0)).toColor();

  Color _darken(Color c, double a) =>
      HSLColor.fromColor(c).withLightness(
          (HSLColor.fromColor(c).lightness - a).clamp(0.0, 1.0)).toColor();

  @override
  bool shouldRepaint(MazePainter old) =>
      old.traversal != traversal ||
      old.pathAnimationProgress != pathAnimationProgress ||
      old.pulseProgress != pulseProgress ||
      old.particleProgress != particleProgress;
}

// ── Hit test ─────────────────────────────────────────────────────────────────
String? hitTestNode(Offset pos, Size size, LevelGraph graph, double threshold) {
  if (graph.gridCols == 0) return null;
  final c  = math.min(size.width / graph.gridCols, size.height / graph.gridRows);
  final ox = (size.width  - c * graph.gridCols) / 2;
  final oy = (size.height - c * graph.gridRows) / 2;
  String? best; double bestDist = double.infinity;
  for (final node in graph.nodes.values) {
    final center = Offset(ox + node.gridX * c + c / 2, oy + node.gridY * c + c / 2);
    final d = (pos - center).distance;
    if (d < bestDist && d <= c * 0.52 + threshold) { bestDist = d; best = node.id; }
  }
  return best;
}
