import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/game_mode.dart';
import '../../common/widgets/countdown_timer_bar.dart';
import '../../common/widgets/option_tile.dart';
import '../../common/widgets/score_chip.dart';
import '../../providers/providers.dart';
import '../state/quiz_state.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, required this.mode});

  final GameMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizViewModelProvider(mode));
    final viewModel = ref.read(quizViewModelProvider(mode).notifier);

    ref.listen(quizViewModelProvider(mode), (previous, next) {
      if (next.status == QuizStatus.finished) {
        context.pushReplacement('/result', extra: next);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(mode.title)),
      body: SafeArea(
        child: switch (state.status) {
          QuizStatus.loading => const Center(child: CircularProgressIndicator()),
          QuizStatus.error => _ErrorView(message: state.errorMessage ?? 'Something went wrong'),
          QuizStatus.finished => const Center(child: CircularProgressIndicator()),
          QuizStatus.inProgress ||
          QuizStatus.answered =>
            _QuizBody(mode: mode, state: state, viewModel: viewModel),
        },
      ),
    );
  }
}

class _QuizBody extends StatelessWidget {
  const _QuizBody({required this.mode, required this.state, required this.viewModel});

  final GameMode mode;
  final QuizState state;
  final dynamic viewModel;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ScoreChip(score: state.score),
              if (state.lives != null)
                LivesIndicator(lives: state.lives!, maxLives: 3)
              else
                StreakChip(streak: state.streak),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Question ${state.currentIndex + 1} of ${state.questions.length}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          if (state.secondsRemaining != null) ...[
            const SizedBox(height: 14),
            CountdownTimerBar(
              secondsRemaining: state.secondsRemaining!,
              totalSeconds: _totalSecondsFor(mode),
            ),
          ],
          const SizedBox(height: 28),
          Text(
            question.category.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.secondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            question.questionText,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final visualState = _visualStateFor(index);
                return OptionTile(
                  label: question.options[index],
                  state: visualState,
                  enabled: state.status == QuizStatus.inProgress,
                  onTap: () => viewModel.selectAnswer(index),
                );
              },
            ),
          ),
          if (state.status == QuizStatus.answered)
            ElevatedButton(
              onPressed: viewModel.nextQuestion,
              child: Text(state.isLastQuestion ? 'See results' : 'Next question'),
            ),
        ],
      ),
    );
  }

  OptionVisualState _visualStateFor(int index) {
    if (state.status != QuizStatus.answered) return OptionVisualState.idle;

    final question = state.currentQuestion!;
    final selected = state.selectedOptionIndex;

    if (index == question.correctIndex) {
      return OptionVisualState.revealedCorrect;
    }
    if (selected == index) {
      return OptionVisualState.selectedWrong;
    }
    return OptionVisualState.idle;
  }

  int _totalSecondsFor(GameMode mode) {
    switch (mode) {
      case GameMode.trueFalseBlitz:
        return 5;
      case GameMode.timedChallenge:
        return 60;
      case GameMode.classicQuiz:
      case GameMode.survivalMode:
        return 0;
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
