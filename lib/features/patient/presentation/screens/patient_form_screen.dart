import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/patient_entity.dart';
import '../cubit/patient_cubit.dart';
import '../cubit/patient_state.dart';

class PatientFormScreen extends StatefulWidget {
  final PatientEntity? patient;

  const PatientFormScreen({
    super.key,
    this.patient,
  });

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  String? _selectedSex;
  DateTime? _selectedBirthDate;

  bool get _isEditMode => widget.patient != null;

  @override
  void initState() {
    super.initState();
    final patient = widget.patient;
    if (patient == null) {
      return;
    }

    _lastNameController.text = patient.lastName;
    _firstNameController.text = patient.firstName;
    _phoneController.text = patient.phone ?? '';
    _selectedSex = patient.sex;
    _selectedBirthDate = patient.birthDate;
    _birthDateController.text = _formatDate(patient.birthDate);
    _bmiController.text = patient.bmi.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _bmiController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate = _selectedBirthDate ?? DateTime(now.year - 30);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedBirthDate = pickedDate;
      _birthDateController.text = _formatDate(pickedDate);
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  double? _parseBmi() {
    final value = _bmiController.text.trim().replaceAll(',', '.');
    return double.tryParse(value);
  }

  String? _validateName(String? value, String label) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Veuillez saisir $label.';
    }

    if (text.length < 2) {
      return '$label doit contenir au moins 2 caractères.';
    }

    return null;
  }

  String? _validateBirthDate(String? value) {
    if (_selectedBirthDate == null) {
      return 'Veuillez sélectionner une date de naissance.';
    }

    final now = DateTime.now();
    if (_selectedBirthDate!.isAfter(now)) {
      return 'La date de naissance doit être dans le passé.';
    }

    final age = now.difference(_selectedBirthDate!).inDays ~/ 365;
    if (age < 0 || age > 120) {
      return "L'âge doit être compris entre 0 et 120 ans.";
    }

    return null;
  }

  String? _validateBmi(String? value) {
    final bmi = _parseBmi();

    if (bmi == null) {
      return 'Veuillez saisir un BMI valide.';
    }

    if (bmi < 10 || bmi > 80) {
      return 'Le BMI doit être compris entre 10 et 80.';
    }

    return null;
  }

  Widget? _buildBmiCategoryChip() {
    final bmi = _parseBmi();
    if (bmi == null) {
      return null;
    }

    late String label;
    late Color color;

    if (bmi < 18.5) {
      label = 'Insuffisance pondérale';
      color = Colors.blue;
    } else if (bmi < 25) {
      label = 'Poids normal';
      color = Colors.green;
    } else if (bmi < 30) {
      label = 'Surpoids';
      color = Colors.amber;
    } else {
      label = 'Obésité';
      color = Colors.red;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(label),
        backgroundColor: color.withValues(alpha: 0.18),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        labelStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final existing = widget.patient;
    final patient = PatientEntity(
      id: existing?.id,
      lastName: _lastNameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      sex: _selectedSex!,
      birthDate: _selectedBirthDate!,
      bmi: _parseBmi()!,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditMode) {
      context.read<PatientCubit>().updatePatient(patient);
      return;
    }

    context.read<PatientCubit>().createPatient(patient);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientCubit, PatientState>(
      listener: (context, state) {
        if (state is PatientOperationSuccess) {
          final messenger = ScaffoldMessenger.of(context);
          Navigator.of(context).pop();
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF1D9E75),
              ),
            );
        } else if (state is PatientError) {
          showErrorSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'Modifier patient' : 'Nouveau patient'),
        ),
        body: BlocBuilder<PatientCubit, PatientState>(
          builder: (context, state) {
            final isLoading = state is PatientLoading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _lastNameController,
                        label: 'Nom',
                        validator: (value) => _validateName(value, 'le nom'),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _firstNameController,
                        label: 'Prénom',
                        validator: (value) => _validateName(value, 'le prénom'),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _phoneController,
                        label: 'Téléphone',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSex,
                        decoration: const InputDecoration(
                          labelText: 'Sexe',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Masculin',
                            child: Text('Masculin'),
                          ),
                          DropdownMenuItem(
                            value: 'Féminin',
                            child: Text('Féminin'),
                          ),
                        ],
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedSex = value;
                                });
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner le sexe.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _birthDateController,
                        label: 'Date de naissance',
                        readOnly: true,
                        onTap: _pickBirthDate,
                        validator: _validateBirthDate,
                        suffixIcon: IconButton(
                          onPressed: isLoading ? null : _pickBirthDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _bmiController,
                        label: 'BMI (kg/m²)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validateBmi,
                        helperText: 'Indice de masse corporelle',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      if (_buildBmiCategoryChip() != null)
                        _buildBmiCategoryChip()!,
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: const Text('Annuler'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppButton(
                              label: 'Enregistrer',
                              isLoading: isLoading,
                              onPressed: isLoading ? null : _submit,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
