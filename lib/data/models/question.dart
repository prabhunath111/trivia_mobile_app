import 'package:equatable/equatable.dart';

/// Core Model layer (MVVM) representing a single trivia question.
/// Immutable and framework-agnostic so it can be reused by every game mode.
class Question extends Equatable {
  const Question({
    required this.id,
    required this.category,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.difficulty,
  });

  final String id;
  final String category;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String difficulty;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      category: json['category'] as String,
      questionText: json['questionText'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'questionText': questionText,
        'options': options,
        'correctIndex': correctIndex,
        'difficulty': difficulty,
      };

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;

  @override
  List<Object?> get props => [id, category, questionText, options, correctIndex, difficulty];
}
