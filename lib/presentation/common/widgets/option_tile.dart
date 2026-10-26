import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum OptionVisualState { idle, selectedCorrect, selectedWrong, revealedCorrect }

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final OptionVisualState state;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(state);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                ),
                if (state == OptionVisualState.selectedCorrect ||
                    state == OptionVisualState.revealedCorrect)
                  const Icon(Icons.check_circle, color: AppTheme.success)
                else if (state == OptionVisualState.selectedWrong)
                  const Icon(Icons.cancel, color: AppTheme.error),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _OptionColors _colorsFor(OptionVisualState state) {
    switch (state) {
      case OptionVisualState.idle:
        return const _OptionColors(
          background: AppTheme.surface,
          border: Colors.white24,
          text: Colors.white,
        );
      case OptionVisualState.selectedCorrect:
      case OptionVisualState.revealedCorrect:
        return _OptionColors(
          background: AppTheme.success.withOpacity(0.18),
          border: AppTheme.success,
          text: Colors.white,
        );
      case OptionVisualState.selectedWrong:
        return _OptionColors(
          background: AppTheme.error.withOpacity(0.18),
          border: AppTheme.error,
          text: Colors.white,
        );
    }
  }
}

class _OptionColors {
  const _OptionColors({
    required this.background,
    required this.border,
    required this.text,
  });

  final Color background;
  final Color border;
  final Color text;
}
