import 'package:flutter_test/flutter_test.dart';
import 'package:trivia_master/core/utils/score_calculator.dart';
import 'package:trivia_master/data/models/game_mode.dart';

void main() {
  final calculator = const ScoreCalculator();

  group('ScoreCalculator - Classic Quiz', () {
    test('awards base points with zero streak', () {
      final points = calculator.pointsForCorrectAnswer(
        mode: GameMode.classicQuiz,
        currentStreak: 0,
      );
      expect(points, ScoreCalculator.basePoints);
    });

    test('adds a growing streak bonus', () {
      final points = calculator.pointsForCorrectAnswer(
        mode: GameMode.classicQuiz,
        currentStreak: 2,
      );
      expect(points, ScoreCalculator.basePoints + 10);
    });

    test('caps the streak bonus at maxStreakBonus', () {
      final points = calculator.pointsForCorrectAnswer(
        mode: GameMode.classicQuiz,
        currentStreak: 100,
      );
      expect(points, ScoreCalculator.basePoints + ScoreCalculator.maxStreakBonus);
    });
  });

  group('ScoreCalculator - True/False Blitz', () {
    test('always awards flat base points regardless of streak', () {
      final points = calculator.pointsForCorrectAnswer(
        mode: GameMode.trueFalseBlitz,
        currentStreak: 5,
      );
      expect(points, ScoreCalculator.basePoints);
    });
  });

  group('ScoreCalculator - Timed Challenge', () {
    test('awards a bonus for answering with time left', () {
      final points = calculator.pointsForCorrectAnswer(
        mode: GameMode.timedChallenge,
        currentStreak: 0,
        secondsRemaining: 60,
        secondsAllotted: 60,
      );
      expect(points, ScoreCalculator.basePoints + 10);
    });

    test('awards zero speed bonus when answered at the last second', () {
      final points = calculator.pointsForCorrectAnswer(
        mode: GameMode.timedChallenge,
        currentStreak: 0,
        secondsRemaining: 0,
        secondsAllotted: 60,
      );
      expect(points, ScoreCalculator.basePoints);
    });

    test('handles missing timing info gracefully', () {
      final points = calculator.pointsForCorrectAnswer(
        mode: GameMode.timedChallenge,
        currentStreak: 0,
      );
      expect(points, ScoreCalculator.basePoints);
    });
  });

  group('ScoreCalculator - Survival Mode', () {
    test('adds streak bonus like Classic Quiz', () {
      final points = calculator.pointsForCorrectAnswer(
        mode: GameMode.survivalMode,
        currentStreak: 3,
      );
      expect(points, ScoreCalculator.basePoints + 15);
    });
  });
}
