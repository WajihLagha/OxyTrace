import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../features/patient/domain/entities/patient_entity.dart';

class PatientTile extends StatelessWidget {
  final PatientEntity patient;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PatientTile({
    super.key,
    required this.patient,
    this.onTap,
    this.onLongPress,
  });

  String get _initials {
    final first = patient.firstName.isNotEmpty ? patient.firstName[0] : '';
    final last = patient.lastName.isNotEmpty ? patient.lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          onTap: onTap,
          onLongPress: onLongPress,
          leading: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            patient.fullName,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${patient.age} ans • ${patient.sex}',
            style: const TextStyle(color: AppColors.muted),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
        ),
        const Divider(height: 1, color: AppColors.surfaceVariant),
      ],
    );
  }
}
