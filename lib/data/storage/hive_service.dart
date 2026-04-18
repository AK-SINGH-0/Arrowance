// lib/data/storage/hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';

class PlayerProgress {
  final int currentLevel;
  final int highestUnlockedLevel;
  final List<int> completedSeeds;

  const PlayerProgress({
    this.currentLevel = 1,
    this.highestUnlockedLevel = 1,
    this.completedSeeds = const [],
  });

  PlayerProgress copyWith({
    int? currentLevel,
    int? highestUnlockedLevel,
    List<int>? completedSeeds,
  }) {
    return PlayerProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      highestUnlockedLevel: highestUnlockedLevel ?? this.highestUnlockedLevel,
      completedSeeds: completedSeeds ?? this.completedSeeds,
    );
  }
}

class HiveService {
  static const String _boxName = 'arrowance_data';
  static const String _keyProgress = 'player_progress';

  Box? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  PlayerProgress loadProgress() {
    if (_box == null) return const PlayerProgress();

    final data = _box!.get(_keyProgress);
    if (data == null || data is! Map) {
      return const PlayerProgress();
    }

    try {
      final map = Map<String, dynamic>.from(data);
      return PlayerProgress(
        currentLevel: map['currentLevel'] as int? ?? 1,
        highestUnlockedLevel: map['highestUnlockedLevel'] as int? ?? 1,
        completedSeeds: (map['completedSeeds'] as List?)?.cast<int>() ?? [],
      );
    } catch (e) {
      return const PlayerProgress();
    }
  }

  Future<void> saveProgress(PlayerProgress progress) async {
    if (_box == null) return;

    final data = <String, dynamic>{
      'currentLevel': progress.currentLevel,
      'highestUnlockedLevel': progress.highestUnlockedLevel,
      'completedSeeds': progress.completedSeeds,
    };

    await _box!.put(_keyProgress, data);
  }
}
