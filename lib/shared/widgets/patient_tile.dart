import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../features/patient/domain/entities/patient_entity.dart';

class PatientTile extends StatelessWidget {
  final PatientEntity patient;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showSyncStatus;

  const PatientTile({
    super.key,
    required this.patient,
    this.onTap,
    this.onLongPress,
    this.showSyncStatus = false,
  });

  String get _initials {
    final first = patient.firstName.isNotEmpty ? patient.firstName[0] : '';
    final last = patient.lastName.isNotEmpty ? patient.lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final statusColor = patient.isSynced ? colors.success : colors.warning;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          onTap: onTap,
          onLongPress: onLongPress,
          leading: CircleAvatar(
            backgroundColor: colors.primary,
            child: Text(
              _initials,
              style: TextStyle(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            patient.fullName,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${patient.age} ans - ${patient.sex}',
            style: TextStyle(color: colors.muted),
          ),
          trailing: showSyncStatus
              ? _SyncStatusBadge(
                  isSynced: patient.isSynced,
                  color: statusColor,
                )
              : Icon(Icons.chevron_right, color: colors.muted),
        ),
        Divider(height: 1, color: colors.surfaceVariant),
      ],
    );
  }
}

class _SyncStatusBadge extends StatelessWidget {
  final bool isSynced;
  final Color color;

  const _SyncStatusBadge({
    required this.isSynced,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 116),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color.withValues(alpha: 0.42)),
            ),
            child: Text(
              isSynced ? 'Synchronisé' : 'En attente',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Icon(Icons.chevron_right, color: colors.muted, size: 18),
        ],
      ),
    );
  }
}
