import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class StepProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final List<String> stepTitles;

  const StepProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < totalSteps; i++) ...[
              _StepChip(
                index: i,
                currentStep: currentStep,
              ),
              if (i < totalSteps - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: i < currentStep
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Text(
          stepTitles[currentStep],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  final int index;
  final int currentStep;

  const _StepChip({
    required this.index,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = index < currentStep;
    final isActive = index == currentStep;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isCompleted || isActive ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isCompleted || isActive
              ? AppColors.primary
              : AppColors.surfaceVariant,
        ),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : Text(
              '${index + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
