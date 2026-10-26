import 'dart:math';
import '../datasources/question_local_datasource.dart';
import '../models/game_mode.dart';
import '../models/question.dart';

/// Repository contract consumed by ViewModels. ViewModels never talk to the
/// datasource directly - this keeps them decoupled and easy to unit test
/// with a fake/mock repository.
abstract class QuestionRepository {
  Future<List<Question>> getQuestionsForConfig(GameConfig config);
}

class QuestionRepositoryImpl implements QuestionRepository {
  QuestionRepositoryImpl(this._localDataSource, {Random? random})
      : _random = random ?? Random();

  final QuestionLocalDataSource _localDataSource;
  final Random _random;

  @override
  Future<List<Question>> getQuestionsForConfig(GameConfig config) async {
    final pool = config.isTrueFalse
        ? await _localDataSource.loadTrueFalseQuestions()
        : await _localDataSource.loadStandardQuestions();

    final shuffled = List<Question>.from(pool)..shuffle(_random);
    final count = min(config.questionCount, shuffled.length);
    return shuffled.take(count).toList();
  }
}
