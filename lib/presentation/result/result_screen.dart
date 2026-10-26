import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/game_mode.dart';
import '../game/state/quiz_state.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final QuizState result;

  @override
  Widget build(BuildContext context) {
    final total = result.questions.length;
    final accuracy = total == 0 ? 0.0 : (result.correctCount / total) * 100;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(result.mode.emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                result.mode.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Game over!', style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _StatRow(label: 'Score', value: '${result.score}', color: AppTheme.warning),
                      const Divider(height: 28, color: Colors.white12),
                      _StatRow(
                        label: 'Correct answers',
                        value: '${result.correctCount} / $total',
                        color: AppTheme.success,
                      ),
                      const Divider(height: 28, color: Colors.white12),
                      _StatRow(
                        label: 'Accuracy',
                        value: '${accuracy.toStringAsFixed(0)}%',
                        color: AppTheme.secondary,
                      ),
                      const Divider(height: 28, color: Colors.white12),
                      _StatRow(
                        label: 'Best streak',
                        value: '${result.bestStreak}',
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Home'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          context.pushReplacement('/game/${result.mode.name}'),
                      child: const Text('Play again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
