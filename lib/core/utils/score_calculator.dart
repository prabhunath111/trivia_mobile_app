import '../../data/models/game_mode.dart';

/// Pure, side-effect-free scoring rules. Extracted from the ViewModel so it
/// can be unit tested in isolation and reused across every game mode.
class ScoreCalculator {
  const ScoreCalculator();

  static const int basePoints = 10;
  static const int streakBonusStep = 5;
  static const int maxStreakBonus = 25;

  /// Points awarded for a single correct answer.
  ///
  /// - Classic Quiz: flat base points + a small streak bonus.
  /// - Timed Challenge: base points + bonus for answering with time left.
  /// - True/False Blitz: flat base points (speed is the challenge already).
  /// - Survival Mode: base points + growing streak bonus (risk/reward).
  int pointsForCorrectAnswer({
    required GameMode mode,
    required int currentStreak,
    int? secondsRemaining,
    int? secondsAllotted,
  }) {
    final streakBonus = _streakBonus(currentStreak);

    switch (mode) {
      case GameMode.classicQuiz:
        return basePoints + streakBonus;
      case GameMode.trueFalseBlitz:
        return basePoints;
      case GameMode.timedChallenge:
        final speedBonus = _speedBonus(secondsRemaining, secondsAllotted);
        return basePoints + speedBonus;
      case GameMode.survivalMode:
        return basePoints + streakBonus;
    }
  }

  int _streakBonus(int currentStreak) {
    final bonus = currentStreak * streakBonusStep;
    return bonus > maxStreakBonus ? maxStreakBonus : bonus;
  }

  int _speedBonus(int? secondsRemaining, int? secondsAllotted) {
    if (secondsRemaining == null || secondsAllotted == null || secondsAllotted == 0) {
      return 0;
    }
    final ratio = secondsRemaining / secondsAllotted;
    return (ratio.clamp(0, 1) * 10).round();
  }
}
