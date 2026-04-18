// lib/features/gameplay/theme/game_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameTheme {
  // ── Brighter, cleaner core palette ────────────────────────────────────────
  static const Color background   = Color(0xFF0A0F21);
  static const Color surface      = Color(0xFF111A35);
  static const Color surfaceHigh  = Color(0xFF1A2545);
  static const Color surfaceBorder = Color(0xFF253058);

  // Vivid node colours
  static const Color nodeNormal   = Color(0xFF2A3A6E);
  static const Color nodeStart    = Color(0xFF00E676);
  static const Color nodeEnd      = Color(0xFFFF1744);
  static const Color pathColor    = Color(0xFF40C4FF);
  static const Color nodeVisited  = Color(0xFF9C6FFF);

  // Accent colours
  static const Color neonCyan     = Color(0xFF00E5FF);
  static const Color neonPurple   = Color(0xFFCE93D8);
  static const Color neonOrange   = Color(0xFFFF7043);
  static const Color neonGold     = Color(0xFFFFD600);
  static const Color neonGreen    = Color(0xFF69FF47);

  static const Color textLight    = Color(0xFFF0F4FF);
  static const Color textMuted    = Color(0xFF8899BB);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0F21), Color(0xFF0F1830), Color(0xFF131028)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient boardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF111A35), Color(0xFF0B1225)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2545), Color(0xFF0F1830)],
  );

  // ── Text styles ───────────────────────────────────────────────────────────
  static TextStyle get titleStyle => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textLight,
    letterSpacing: 0.3,
  );

  static TextStyle get subtitleStyle => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textMuted,
  );

  static TextStyle get labelStyle => GoogleFonts.outfit(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: textMuted,
    letterSpacing: 1.4,
  );

  static TextStyle get monoStyle => GoogleFonts.sourceCodePro(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: textLight,
  );
}

ThemeData buildGameTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: GameTheme.background,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: GameTheme.pathColor,
      secondary: GameTheme.nodeStart,
      surface: GameTheme.surface,
    ),
  );
}
