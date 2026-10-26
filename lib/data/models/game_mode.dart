/// The 4 trivia games bundled into the app.
/// Each mode reuses the same question engine but with a different
/// [GameConfig], which is what gives every mode its distinct feel.
enum GameMode {
  classicQuiz,
  trueFalseBlitz,
  timedChallenge,
  survivalMode,
}

extension GameModeX on GameMode {
  String get title {
    switch (this) {
      case GameMode.classicQuiz:
        return 'Classic Quiz';
      case GameMode.trueFalseBlitz:
        return 'True/False Blitz';
      case GameMode.timedChallenge:
        return 'Timed Challenge';
      case GameMode.survivalMode:
        return 'Survival Mode';
    }
  }

  String get subtitle {
    switch (this) {
      case GameMode.classicQuiz:
        return 'Relaxed multiple choice trivia';
      case GameMode.trueFalseBlitz:
        return 'Rapid-fire true or false rounds';
      case GameMode.timedChallenge:
        return 'Race the clock for bonus points';
      case GameMode.survivalMode:
        return 'One wrong answer and you\'re out';
    }
  }

  String get emoji {
    switch (this) {
      case GameMode.classicQuiz:
        return '🧠';
      case GameMode.trueFalseBlitz:
        return '⚡';
      case GameMode.timedChallenge:
        return '⏱️';
      case GameMode.survivalMode:
        return '❤️';
    }
  }
}

/// Configuration that drives the shared [QuizViewModel] engine.
/// This is the piece that "combines" 4 different games into one engine.
class GameConfig {
  const GameConfig({
    required this.mode,
    required this.questionCount,
    this.perQuestionSeconds,
    this.totalGameSeconds,
    this.livesCount,
    this.isTrueFalse = false,
  });

  final GameMode mode;

  /// How many questions are drawn for a session.
  final int questionCount;

  /// If set, each question has its own countdown; timeout counts as wrong.
  final int? perQuestionSeconds;

  /// If set, the whole session shares one countdown clock.
  final int? totalGameSeconds;

  /// If set, the game ends after this many wrong answers.
  final int? livesCount;

  /// Whether the question set should be sourced from the True/False bank.
  final bool isTrueFalse;

  static const classicQuiz = GameConfig(
    mode: GameMode.classicQuiz,
    questionCount: 10,
  );

  static const trueFalseBlitz = GameConfig(
    mode: GameMode.trueFalseBlitz,
    questionCount: 12,
    perQuestionSeconds: 5,
    isTrueFalse: true,
  );

  static const timedChallenge = GameConfig(
    mode: GameMode.timedChallenge,
    questionCount: 15,
    totalGameSeconds: 60,
  );

  static const survivalMode = GameConfig(
    mode: GameMode.survivalMode,
    questionCount: 20,
    livesCount: 3,
  );

  static GameConfig forMode(GameMode mode) {
    switch (mode) {
      case GameMode.classicQuiz:
        return classicQuiz;
      case GameMode.trueFalseBlitz:
        return trueFalseBlitz;
      case GameMode.timedChallenge:
        return timedChallenge;
      case GameMode.survivalMode:
        return survivalMode;
    }
  }
}
