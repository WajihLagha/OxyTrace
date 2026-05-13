import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/info_row.dart';
import '../../../../shared/widgets/intubation_tile.dart';
import '../../../intubation/domain/entities/intubation_entity.dart';
import '../../../intubation/presentation/cubit/intubation_cubit.dart';
import '../../../intubation/presentation/cubit/intubation_state.dart';
import '../../../intubation/presentation/screens/intubation_detail_screen.dart';
import '../../../intubation/presentation/screens/intubation_form_screen.dart';
import '../../domain/entities/patient_entity.dart';
import '../cubit/patient_cubit.dart';
import '../cubit/patient_state.dart';
import 'patient_form_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final PatientEntity patient;

  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late PatientEntity _patient;

  @override
  void initState() {
    super.initState();
    _patient = widget.patient;
    context.read<IntubationCubit>().loadIntubationsByPatient(_patient.id!);
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) {
      return 'Insuffisance pondérale';
    }
    if (bmi < 25) {
      return 'Poids normal';
    }
    if (bmi < 30) {
      return 'Surpoids';
    }
    return 'Obésité';
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) {
      return AppColors.info;
    }
    if (bmi < 25) {
      return AppColors.success;
    }
    if (bmi < 30) {
      return AppColors.warning;
    }
    return AppColors.danger;
  }

  String get _initials {
    final first = _patient.firstName.isNotEmpty ? _patient.firstName[0] : '';
    final last = _patient.lastName.isNotEmpty ? _patient.lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  Future<void> _openEditScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PatientFormScreen(patient: _patient),
      ),
    );
  }

  Future<void> _confirmDeletePatient() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer le patient'),
          content: Text(
            'Voulez-vous vraiment supprimer ${_patient.fullName} ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && _patient.id != null && mounted) {
      await context.read<PatientCubit>().deletePatient(_patient.id!);
    }
  }

  Future<void> _openIntubationForm({IntubationEntity? intubation}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => IntubationFormScreen(
          patient: _patient,
          intubation: intubation,
        ),
      ),
    );
  }

  Future<void> _openIntubationDetail(IntubationEntity intubation) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => IntubationDetailScreen(
          intubation: intubation,
          patient: _patient,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteIntubation(IntubationEntity intubation) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer le dossier'),
          content: const Text(
            "Voulez-vous vraiment supprimer ce dossier d'intubation ?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && intubation.id != null && mounted) {
      await context.read<IntubationCubit>().deleteIntubation(intubation.id!);
    }
  }

  void _showIntubationOptions(IntubationEntity intubation) {
    showModalBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _openIntubationForm(intubation: intubation);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _confirmDeleteIntubation(intubation);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIntubationSection() {
    return BlocBuilder<IntubationCubit, IntubationState>(
      builder: (context, state) {
        if (state is IntubationLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (state is IntubationError) {
          return ErrorState(
            message: state.message,
            onRetry: () => context
                .read<IntubationCubit>()
                .loadIntubationsByPatient(_patient.id!),
          );
        }

        if (state is IntubationListLoaded) {
          if (state.intubations.isEmpty) {
            return EmptyState(
              icon: Icons.description_outlined,
              title: "Aucun dossier d'intubation",
              subtitle: 'Créez un dossier pour ce patient.',
              action: OutlinedButton.icon(
                onPressed: _openIntubationForm,
                icon: const Icon(Icons.add),
                label: const Text('Nouveau dossier'),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.intubations.length,
            itemBuilder: (context, index) {
              final intubation = state.intubations[index];
              return IntubationTile(
                intubation: intubation,
                onTap: () => _openIntubationDetail(intubation),
                onLongPress: () => _showIntubationOptions(intubation),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bmiColor = _bmiColor(_patient.bmi);

    return MultiBlocListener(
      listeners: [
        BlocListener<PatientCubit, PatientState>(
          listener: (context, state) {
            if (state is PatientOperationSuccess &&
                state.patient.id == _patient.id) {
              setState(() {
                _patient = state.patient;
              });
            } else if (state is PatientDeleted) {
              Navigator.of(context).pop();
            }
          },
        ),
        BlocListener<IntubationCubit, IntubationState>(
          listener: (context, state) {
            if (state is IntubationDeleted) {
              showSuccessSnackBar(context, "Dossier d'intubation supprimé.");
            } else if (state is IntubationError) {
              showErrorSnackBar(context, state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(_patient.fullName),
          actions: [
            IconButton(
              onPressed: _openEditScreen,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _patient.fullName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_patient.age} ans • ${_patient.sex}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Créé le ${DateFormatter.toDisplayWithTime(_patient.createdAt)}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations générales',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      InfoRow(label: 'Nom complet', value: _patient.fullName),
                      InfoRow(label: 'Âge', value: '${_patient.age} ans'),
                      InfoRow(label: 'Sexe', value: _patient.sex),
                      InfoRow(
                        label: 'Date de naissance',
                        value: DateFormatter.toDisplay(_patient.birthDate),
                      ),
                      InfoRow(
                        label: 'Téléphone',
                        value: _patient.phone?.isNotEmpty == true
                            ? _patient.phone!
                            : 'Non renseigné',
                      ),
                      InfoRow(
                        label: 'BMI',
                        value: _patient.bmi.toStringAsFixed(1),
                        trailing: Chip(
                          label: Text(_bmiCategory(_patient.bmi)),
                          backgroundColor: bmiColor.withValues(alpha: 0.18),
                          side: BorderSide(color: bmiColor.withValues(alpha: 0.4)),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Dossiers d'intubation",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildIntubationSection(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Zone de danger',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _confirmDeletePatient,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.danger),
                          foregroundColor: AppColors.danger,
                        ),
                        child: const Text('Supprimer le patient'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
