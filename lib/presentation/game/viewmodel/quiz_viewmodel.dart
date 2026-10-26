import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/score_calculator.dart';
import '../../../data/models/game_mode.dart';
import '../../../data/repositories/question_repository.dart';
import '../state/quiz_state.dart';

/// ViewModel (MVVM) - shared "engine" that powers Classic Quiz,
/// True/False Blitz, Timed Challenge and Survival Mode.
///
/// Each mode only differs by its [GameConfig] (question count, per-question
/// timer, total timer, lives) which keeps the logic in one well-tested place
/// while each screen (View) still renders its own distinct UI.
class QuizViewModel extends StateNotifier<QuizState> {
  QuizViewModel({
    required QuestionRepository repository,
    required ScoreCalculator scoreCalculator,
    required GameConfig config,
  })  : _repository = repository,
        _scoreCalculator = scoreCalculator,
        _config = config,
        super(QuizState(mode: config.mode)) {
    _start();
  }

  final QuestionRepository _repository;
  final ScoreCalculator _scoreCalculator;
  final GameConfig _config;

  Timer? _timer;

  Future<void> _start() async {
    try {
      final questions = await _repository.getQuestionsForConfig(_config);
      if (questions.isEmpty) {
        state = state.copyWith(
          status: QuizStatus.error,
          errorMessage: 'No questions available for this game mode.',
        );
        return;
      }

      state = state.copyWith(
        status: QuizStatus.inProgress,
        questions: questions,
        currentIndex: 0,
        lives: _config.livesCount,
        secondsRemaining: _config.totalGameSeconds ?? _config.perQuestionSeconds,
      );

      _maybeStartTimer();
    } catch (e) {
      state = state.copyWith(
        status: QuizStatus.error,
        errorMessage: 'Failed to load questions: $e',
      );
    }
  }

  void _maybeStartTimer() {
    _timer?.cancel();
    final hasTimer =
        _config.totalGameSeconds != null || _config.perQuestionSeconds != null;
    if (!hasTimer) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _onTick() {
    if (state.status != QuizStatus.inProgress) return;
    final remaining = (state.secondsRemaining ?? 1) - 1;

    if (remaining <= 0) {
      if (_config.totalGameSeconds != null) {
        // Whole-game clock ran out -> game over.
        state = state.copyWith(secondsRemaining: 0);
        _finish();
      } else {
        // Per-question clock ran out -> counts as a wrong / skipped answer.
        state = state.copyWith(secondsRemaining: 0);
        selectAnswer(-1);
      }
      return;
    }

    state = state.copyWith(secondsRemaining: remaining);
  }

  /// Called when the player taps an option. [selectedIndex] of -1 means a
  /// timeout (no answer selected).
  void selectAnswer(int selectedIndex) {
    if (state.status != QuizStatus.inProgress) return;
    final question = state.currentQuestion;
    if (question == null) return;

    final isCorrect = selectedIndex != -1 && question.isCorrect(selectedIndex);
    final newStreak = isCorrect ? state.streak + 1 : 0;
    final newBestStreak =
        newStreak > state.bestStreak ? newStreak : state.bestStreak;

    int newScore = state.score;
    if (isCorrect) {
      newScore += _scoreCalculator.pointsForCorrectAnswer(
        mode: _config.mode,
        currentStreak: state.streak,
        secondsRemaining: state.secondsRemaining,
        secondsAllotted: _config.perQuestionSeconds,
      );
    }

    int? newLives = state.lives;
    if (!isCorrect && newLives != null) {
      newLives -= 1;
    }

    state = state.copyWith(
      status: QuizStatus.answered,
      selectedOptionIndex: selectedIndex == -1 ? null : selectedIndex,
      score: newScore,
      correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
      streak: newStreak,
      bestStreak: newBestStreak,
      lives: newLives,
    );

    // Survival Mode ends immediately once lives run out.
    if (newLives != null && newLives <= 0) {
      Future<void>.delayed(const Duration(milliseconds: 700), _finish);
    }
  }

  void nextQuestion() {
    if (state.status != QuizStatus.answered) return;

    if (state.isLastQuestion) {
      _finish();
      return;
    }

    state = state.copyWith(
      status: QuizStatus.inProgress,
      currentIndex: state.currentIndex + 1,
      clearSelectedOption: true,
      secondsRemaining: _config.perQuestionSeconds != null
          ? _config.perQuestionSeconds
          : state.secondsRemaining,
    );
  }

  void _finish() {
    _timer?.cancel();
    if (state.status == QuizStatus.finished) return;
    state = state.copyWith(status: QuizStatus.finished);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
