import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CountdownTimerBar extends StatelessWidget {
  const CountdownTimerBar({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  final int secondsRemaining;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final ratio = totalSeconds == 0
        ? 0.0
        : (secondsRemaining / totalSeconds).clamp(0.0, 1.0);
    final isLow = ratio < 0.25;

    return Row(
      children: [
        Icon(Icons.timer_outlined,
            size: 18, color: isLow ? AppTheme.error : Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                isLow ? AppTheme.error : AppTheme.secondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${secondsRemaining}s',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLow ? AppTheme.error : Colors.white70,
          ),
        ),
      ],
    );
  }
}
