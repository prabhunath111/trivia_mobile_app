import 'package:get_it/get_it.dart';
import '../../data/datasources/question_local_datasource.dart';
import '../../data/repositories/question_repository.dart';
import '../utils/score_calculator.dart';

final GetIt getIt = GetIt.instance;

/// Registers every dependency once, at app startup. Riverpod providers pull
/// their concrete implementations from here, keeping DI and state
/// management as two separate, single-purpose layers.
void setupServiceLocator() {
  getIt.registerLazySingleton<QuestionLocalDataSource>(
    () => QuestionLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(getIt<QuestionLocalDataSource>()),
  );

  getIt.registerLazySingleton<ScoreCalculator>(
    () => const ScoreCalculator(),
  );
}

/// Allows tests to reset and re-register fakes/mocks between test cases.
Future<void> resetServiceLocator() async {
  await getIt.reset();
}
