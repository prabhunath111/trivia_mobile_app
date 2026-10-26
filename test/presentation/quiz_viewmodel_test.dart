import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivia_master/core/utils/score_calculator.dart';
import 'package:trivia_master/data/models/game_mode.dart';
import 'package:trivia_master/data/models/question.dart';
import 'package:trivia_master/data/repositories/question_repository.dart';
import 'package:trivia_master/presentation/game/state/quiz_state.dart';
import 'package:trivia_master/presentation/game/viewmodel/quiz_viewmodel.dart';

class _FakeQuestionRepository implements QuestionRepository {
  _FakeQuestionRepository(this.questions);

  final List<Question> questions;

  @override
  Future<List<Question>> getQuestionsForConfig(GameConfig config) async {
    return questions.take(config.questionCount).toList();
  }
}

List<Question> _buildQuestions(int count, {int optionCount = 4}) {
  return List.generate(count, (i) {
    return Question(
      id: 'q$i',
      category: 'General',
      questionText: 'Question $i',
      options: List.generate(optionCount, (o) => 'Option $o'),
      correctIndex: 0,
      difficulty: 'easy',
    );
  });
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  const scoreCalculator = ScoreCalculator();

  group('QuizViewModel - Classic Quiz', () {
    test('loads questions and starts in progress', () async {
      final repo = _FakeQuestionRepository(_buildQuestions(10));
      final vm = QuizViewModel(
        repository: repo,
        scoreCalculator: scoreCalculator,
        config: GameConfig.classicQuiz,
      );

      await _flush();

      expect(vm.state.status, QuizStatus.inProgress);
      expect(vm.state.questions.length, GameConfig.classicQuiz.questionCount);
      vm.dispose();
    });

    test('selecting the correct answer increases score and correctCount', () async {
      final repo = _FakeQuestionRepository(_buildQuestions(10));
      final vm = QuizViewModel(
        repository: repo,
        scoreCalculator: scoreCalculator,
        config: GameConfig.classicQuiz,
      );
      await _flush();

      vm.selectAnswer(0); // correctIndex is always 0 in test data

      expect(vm.state.status, QuizStatus.answered);
      expect(vm.state.correctCount, 1);
      expect(vm.state.score, ScoreCalculator.basePoints);
      expect(vm.state.streak, 1);
      vm.dispose();
    });

    test('selecting a wrong answer resets the streak and does not score', () async {
      final repo = _FakeQuestionRepository(_buildQuestions(10));
      final vm = QuizViewModel(
        repository: repo,
        scoreCalculator: scoreCalculator,
        config: GameConfig.classicQuiz,
      );
      await _flush();

      vm.selectAnswer(1); // wrong

      expect(vm.state.correctCount, 0);
      expect(vm.state.score, 0);
      expect(vm.state.streak, 0);
      vm.dispose();
    });

    test('nextQuestion advances currentIndex and clears the selected option', () async {
      final repo = _FakeQuestionRepository(_buildQuestions(10));
      final vm = QuizViewModel(
        repository: repo,
        scoreCalculator: scoreCalculator,
        config: GameConfig.classicQuiz,
      );
      await _flush();

      vm.selectAnswer(0);
      vm.nextQuestion();

      expect(vm.state.currentIndex, 1);
      expect(vm.state.selectedOptionIndex, isNull);
      expect(vm.state.status, QuizStatus.inProgress);
      vm.dispose();
    });

    test('finishes the game after the last question is answered', () async {
      final repo = _FakeQuestionRepository(_buildQuestions(1));
      final vm = QuizViewModel(
        repository: repo,
        scoreCalculator: scoreCalculator,
        config: const GameConfig(mode: GameMode.classicQuiz, questionCount: 1),
      );
      await _flush();

      vm.selectAnswer(0);
      vm.nextQuestion();

      expect(vm.state.status, QuizStatus.finished);
      vm.dispose();
    });
  });

  group('QuizViewModel - True/False Blitz', () {
    test('a per-question timeout counts as a wrong answer', () {
      fakeAsync((async) {
        final repo = _FakeQuestionRepository(_buildQuestions(3, optionCount: 2));
        final vm = QuizViewModel(
          repository: repo,
          scoreCalculator: scoreCalculator,
          config: GameConfig.trueFalseBlitz,
        );
        async.flushMicrotasks();

        expect(vm.state.secondsRemaining, GameConfig.trueFalseBlitz.perQuestionSeconds);

        async.elapse(const Duration(
            seconds: 6)); // > perQuestionSeconds -> should time out

        expect(vm.state.status, QuizStatus.answered);
        expect(vm.state.correctCount, 0);
        expect(vm.state.selectedOptionIndex, isNull);
        vm.dispose();
      });
    });
  });

  group('QuizViewModel - Timed Challenge', () {
    test('the whole game ends when the total clock reaches zero', () {
      fakeAsync((async) {
        final repo = _FakeQuestionRepository(_buildQuestions(15));
        final vm = QuizViewModel(
          repository: repo,
          scoreCalculator: scoreCalculator,
          config: GameConfig.timedChallenge,
        );
        async.flushMicrotasks();

        expect(vm.state.secondsRemaining, GameConfig.timedChallenge.totalGameSeconds);

        async.elapse(const Duration(seconds: 61));

        expect(vm.state.status, QuizStatus.finished);
        vm.dispose();
      });
    });

    test('answering correctly with time left grants a speed bonus', () async {
      final repo = _FakeQuestionRepository(_buildQuestions(15));
      final vm = QuizViewModel(
        repository: repo,
        scoreCalculator: scoreCalculator,
        config: GameConfig.timedChallenge,
      );
      await _flush();

      vm.selectAnswer(0);

      expect(vm.state.score, greaterThan(ScoreCalculator.basePoints));
      vm.dispose();
    });
  });

  group('QuizViewModel - Survival Mode', () {
    test('loses a life on a wrong answer', () async {
      final repo = _FakeQuestionRepository(_buildQuestions(20));
      final vm = QuizViewModel(
        repository: repo,
        scoreCalculator: scoreCalculator,
        config: GameConfig.survivalMode,
      );
      await _flush();

      expect(vm.state.lives, GameConfig.survivalMode.livesCount);

      vm.selectAnswer(1); // wrong

      expect(vm.state.lives, GameConfig.survivalMode.livesCount! - 1);
      vm.dispose();
    });

    test('game ends once lives reach zero', () {
      fakeAsync((async) {
        final repo = _FakeQuestionRepository(_buildQuestions(20));
        final vm = QuizViewModel(
          repository: repo,
          scoreCalculator: scoreCalculator,
          config: const GameConfig(
            mode: GameMode.survivalMode,
            questionCount: 20,
            livesCount: 1,
          ),
        );
        async.flushMicrotasks();

        vm.selectAnswer(1); // wrong answer -> lives hits 0
        async.elapse(const Duration(seconds: 1)); // let the finish delay fire

        expect(vm.state.status, QuizStatus.finished);
        vm.dispose();
      });
    });
  });
}
