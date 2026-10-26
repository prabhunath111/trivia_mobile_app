import 'package:equatable/equatable.dart';
import '../../../data/models/game_mode.dart';
import '../../../data/models/question.dart';

enum QuizStatus { loading, inProgress, answered, finished, error }

class QuizState extends Equatable {
  const QuizState({
    required this.mode,
    this.status = QuizStatus.loading,
    this.questions = const [],
    this.currentIndex = 0,
    this.score = 0,
    this.correctCount = 0,
    this.streak = 0,
    this.bestStreak = 0,
    this.lives,
    this.selectedOptionIndex,
    this.secondsRemaining,
    this.errorMessage,
  });

  final GameMode mode;
  final QuizStatus status;
  final List<Question> questions;
  final int currentIndex;
  final int score;
  final int correctCount;
  final int streak;
  final int bestStreak;

  /// Null when the mode has unlimited lives (e.g. Classic Quiz).
  final int? lives;

  /// The option the player tapped for the current question, if any.
  final int? selectedOptionIndex;

  /// Countdown value driving the on-screen timer, if the mode has one.
  final int? secondsRemaining;

  final String? errorMessage;

  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get isLastQuestion => currentIndex >= questions.length - 1;

  double get progress =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  QuizState copyWith({
    QuizStatus? status,
    List<Question>? questions,
    int? currentIndex,
    int? score,
    int? correctCount,
    int? streak,
    int? bestStreak,
    int? lives,
    bool clearLives = false,
    int? selectedOptionIndex,
    bool clearSelectedOption = false,
    int? secondsRemaining,
    bool clearSecondsRemaining = false,
    String? errorMessage,
  }) {
    return QuizState(
      mode: mode,
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      lives: clearLives ? null : (lives ?? this.lives),
      selectedOptionIndex: clearSelectedOption
          ? null
          : (selectedOptionIndex ?? this.selectedOptionIndex),
      secondsRemaining: clearSecondsRemaining
          ? null
          : (secondsRemaining ?? this.secondsRemaining),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        status,
        questions,
        currentIndex,
        score,
        correctCount,
        streak,
        bestStreak,
        lives,
        selectedOptionIndex,
        secondsRemaining,
        errorMessage,
      ];
}
