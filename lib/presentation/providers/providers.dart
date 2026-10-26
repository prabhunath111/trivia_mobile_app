import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/service_locator.dart';
import '../../core/utils/score_calculator.dart';
import '../../data/models/game_mode.dart';
import '../../data/repositories/question_repository.dart';
import '../game/state/quiz_state.dart';
import '../game/viewmodel/quiz_viewmodel.dart';

/// Exposes the get_it-registered repository to Riverpod without duplicating
/// its construction logic - get_it stays the single source of truth for DI.
final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return getIt<QuestionRepository>();
});

final scoreCalculatorProvider = Provider<ScoreCalculator>((ref) {
  return getIt<ScoreCalculator>();
});

/// One independent ViewModel instance per game mode, created on demand and
/// disposed automatically by Riverpod when the game screen is popped.
final quizViewModelProvider = StateNotifierProvider.autoDispose.family<QuizViewModel,
    QuizState, GameMode>((ref, mode) {
  return QuizViewModel(
    repository: ref.watch(questionRepositoryProvider),
    scoreCalculator: ref.watch(scoreCalculatorProvider),
    config: GameConfig.forMode(mode),
  );
});
