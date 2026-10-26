import 'package:equatable/equatable.dart';
import 'game_mode.dart';

class GameResult extends Equatable {
  const GameResult({
    required this.mode,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.bestStreak,
  });

  final GameMode mode;
  final int score;
  final int correctCount;
  final int totalQuestions;
  final int bestStreak;

  double get accuracy =>
      totalQuestions == 0 ? 0 : (correctCount / totalQuestions) * 100;

  @override
  List<Object?> get props =>
      [mode, score, correctCount, totalQuestions, bestStreak];
}
