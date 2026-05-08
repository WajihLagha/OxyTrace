import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SegmentedSelector extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;
  final bool required;
  final bool showError;
  final Widget? trailing;

  const SegmentedSelector({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.required = false,
    this.showError = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = required && showError && selected == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => onSelect(options[i]),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selected == options[i]
                          ? AppColors.primary
                          : AppColors.surface,
                      side: BorderSide(
                        color: selected == options[i]
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        width: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      options[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected == options[i]
                            ? Colors.white
                            : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          const Text(
            'Ce champ est obligatoire.',
            style: TextStyle(color: AppColors.danger, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
