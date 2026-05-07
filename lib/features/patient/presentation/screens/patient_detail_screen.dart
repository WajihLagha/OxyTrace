import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/info_row.dart';
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
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _formatDateTime(DateTime date) {
    final formattedDate = _formatDate(date);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$formattedDate à $hour:$minute';
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
      return Colors.blue;
    }
    if (bmi < 25) {
      return Colors.green;
    }
    if (bmi < 30) {
      return Colors.amber;
    }
    return Colors.red;
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

  Future<void> _confirmDelete() async {
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
                style: TextStyle(color: Colors.redAccent),
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

  @override
  Widget build(BuildContext context) {
    final bmiColor = _bmiColor(_patient.bmi);

    return BlocListener<PatientCubit, PatientState>(
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF1D9E75),
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
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_patient.age} ans • ${_patient.sex}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.68),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Créé le ${_formatDateTime(_patient.createdAt)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations générales',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    InfoRow(label: 'Nom complet', value: _patient.fullName),
                    InfoRow(label: 'Âge', value: '${_patient.age} ans'),
                    InfoRow(label: 'Sexe', value: _patient.sex),
                    InfoRow(
                      label: 'Date de naissance',
                      value: _formatDate(_patient.birthDate),
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
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Dossiers d'intubation",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fonctionnalité à venir'),
                          ),
                        );
                      },
                      child: const Text('Nouveau dossier'),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const PatientTilePlaceholder(),
                          const SizedBox(height: 12),
                          Text(
                            "Aucun dossier d'intubation",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.68),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Zone de danger',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade200,
                          ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _confirmDelete,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade300),
                        foregroundColor: Colors.red.shade200,
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
    );
  }
}

class PatientTilePlaceholder extends StatelessWidget {
  const PatientTilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.description_outlined, color: Colors.white54),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dossier à venir'),
              const SizedBox(height: 4),
              Text(
                'La liste des dossiers sera disponible à l’étape suivante.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
