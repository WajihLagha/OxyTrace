import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../features/intubation/domain/entities/intubation_entity.dart';

class IntubationTile extends StatelessWidget {
  final IntubationEntity intubation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const IntubationTile({
    super.key,
    required this.intubation,
    this.onTap,
    this.onLongPress,
  });

  Color get _badgeColor =>
      intubation.intubationPrevue == 'Difficile'
          ? AppColors.danger
          : AppColors.success;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          onTap: onTap,
          onLongPress: onLongPress,
          title: Text(
            DateFormatter.toDisplay(intubation.createdAt),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            'Cormack ${intubation.scoreCormack ?? "-"} · '
            '${intubation.nombreTentatives ?? 1} tentative(s)',
            style: const TextStyle(color: AppColors.muted),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _badgeColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  intubation.intubationPrevue ?? 'Non précisée',
                  style: TextStyle(
                    color: _badgeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.surfaceVariant),
      ],
    );
  }
}
