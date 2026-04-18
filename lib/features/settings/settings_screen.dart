// lib/features/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:arrowance/features/gameplay/theme/game_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: GameTheme.textLight),
        title: Text('Settings', style: GameTheme.titleStyle),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: GameTheme.bgGradient),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionHeader('GAME GUIDE'),
            _buildCard(
              icon: Icons.lightbulb_outline,
              title: 'How to Play',
              content: 'The goal of Arrowance is to guide the glowing energy from the green start node to the red end node.\n\n'
                  '• You must visit EVERY node exactly once.\n'
                  '• Beware of traps and dead-ends.\n'
                  '• Watch the timer! Harder levels give you more time.',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('ABOUT'),
            _buildCard(
              icon: Icons.info_outline,
              title: 'About the App',
              content: 'Arrowance: The Neon Path Puzzle\nVersion: 1.0.0\n\n'
                  'Developed for puzzle enthusiasts who enjoy mathematical Hamiltonian graph challenges!',
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              content: 'Arrowance does not collect any personal data. All level progress and completed seeds are stored entirely locally on your device.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GameTheme.subtitleStyle.copyWith(
          letterSpacing: 2.0,
          color: GameTheme.pathColor,
        ),
      ),
    );
  }

  Widget _buildCard({required IconData icon, required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameTheme.nodeNormal.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameTheme.nodeNormal.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 24),
              const SizedBox(width: 12),
              Text(title, style: GameTheme.titleStyle.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: GameTheme.subtitleStyle.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
