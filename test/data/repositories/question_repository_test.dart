import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:trivia_master/data/datasources/question_local_datasource.dart';
import 'package:trivia_master/data/models/game_mode.dart';
import 'package:trivia_master/data/models/question.dart';
import 'package:trivia_master/data/repositories/question_repository.dart';

class _FakeQuestionLocalDataSource implements QuestionLocalDataSource {
  _FakeQuestionLocalDataSource({
    required this.standardQuestions,
    required this.trueFalseQuestions,
  });

  final List<Question> standardQuestions;
  final List<Question> trueFalseQuestions;

  @override
  Future<List<Question>> loadStandardQuestions() async => standardQuestions;

  @override
  Future<List<Question>> loadTrueFalseQuestions() async => trueFalseQuestions;
}

Question _q(String id) => Question(
      id: id,
      category: 'General',
      questionText: 'Question $id',
      options: const ['A', 'B', 'C', 'D'],
      correctIndex: 0,
      difficulty: 'easy',
    );

Question _tf(String id) => Question(
      id: id,
      category: 'General',
      questionText: 'True or false $id',
      options: const ['True', 'False'],
      correctIndex: 0,
      difficulty: 'easy',
    );

void main() {
  late _FakeQuestionLocalDataSource fakeDataSource;
  late QuestionRepositoryImpl repository;

  setUp(() {
    fakeDataSource = _FakeQuestionLocalDataSource(
      standardQuestions: List.generate(30, (i) => _q('q$i')),
      trueFalseQuestions: List.generate(15, (i) => _tf('tf$i')),
    );
    // Fixed seed -> deterministic shuffling for reliable assertions.
    repository = QuestionRepositoryImpl(fakeDataSource, random: Random(42));
  });

  test('returns exactly questionCount questions for Classic Quiz', () async {
    final result = await repository.getQuestionsForConfig(GameConfig.classicQuiz);
    expect(result.length, GameConfig.classicQuiz.questionCount);
  });

  test('returns questions from the True/False bank for True/False Blitz', () async {
    final result =
        await repository.getQuestionsForConfig(GameConfig.trueFalseBlitz);
    expect(result.length, GameConfig.trueFalseBlitz.questionCount);
    for (final question in result) {
      expect(question.options, hasLength(2));
    }
  });

  test('never returns more questions than are available in the pool', () async {
    final smallDataSource = _FakeQuestionLocalDataSource(
      standardQuestions: List.generate(3, (i) => _q('q$i')),
      trueFalseQuestions: const [],
    );
    final smallRepo = QuestionRepositoryImpl(smallDataSource, random: Random(1));

    final result = await smallRepo.getQuestionsForConfig(GameConfig.classicQuiz);
    expect(result.length, 3);
  });

  test('does not return duplicate questions within a single session', () async {
    final result =
        await repository.getQuestionsForConfig(GameConfig.survivalMode);
    final ids = result.map((q) => q.id).toSet();
    expect(ids.length, result.length);
  });
}
