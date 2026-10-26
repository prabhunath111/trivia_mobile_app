import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ScoreChip extends StatelessWidget {
  const ScoreChip({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return _Chip(
      icon: Icons.star_rounded,
      iconColor: AppTheme.warning,
      label: '$score',
    );
  }
}

class StreakChip extends StatelessWidget {
  const StreakChip({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    if (streak < 2) return const SizedBox.shrink();
    return _Chip(
      icon: Icons.local_fire_department_rounded,
      iconColor: Colors.orangeAccent,
      label: '$streak streak',
    );
  }
}

class LivesIndicator extends StatelessWidget {
  const LivesIndicator({super.key, required this.lives, required this.maxLives});

  final int lives;
  final int maxLives;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (i) {
        final filled = i < lives;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(
            filled ? Icons.favorite : Icons.favorite_border,
            color: filled ? AppTheme.error : Colors.white30,
            size: 20,
          ),
        );
      }),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.iconColor, required this.label});

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
