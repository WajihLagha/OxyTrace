import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/patient_tile.dart';
import '../../domain/entities/patient_entity.dart';
import '../cubit/patient_cubit.dart';
import '../cubit/patient_state.dart';
import 'patient_detail_screen.dart';
import 'patient_form_screen.dart';

class PatientListScreen extends StatefulWidget {
  final bool openSearch;

  const PatientListScreen({
    super.key,
    this.openSearch = false,
  });

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  int _searchRequestId = 0;

  @override
  void initState() {
    super.initState();
    _isSearching = widget.openSearch;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientCubit>().loadPatients();
      if (_isSearching) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (_isSearching) {
      _searchFocusNode.requestFocus();
      return;
    }

    _searchController.clear();
    context.read<PatientCubit>().loadPatients();
  }

  void _onSearchChanged(String query) {
    _searchRequestId++;
    final currentRequestId = _searchRequestId;

    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (!mounted || currentRequestId != _searchRequestId) {
        return;
      }

      if (query.trim().isEmpty) {
        context.read<PatientCubit>().loadPatients();
        return;
      }

      context.read<PatientCubit>().searchPatients(query);
    });
  }

  Future<void> _openPatientForm({PatientEntity? patient}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PatientFormScreen(patient: patient),
      ),
    );
  }

  Future<void> _openPatientDetail(PatientEntity patient) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PatientDetailScreen(patient: patient),
      ),
    );
  }

  Future<void> _confirmDelete(PatientEntity patient) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer le patient'),
          content: Text(
            'Voulez-vous vraiment supprimer ${patient.fullName} ?',
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

    if (shouldDelete == true && patient.id != null && mounted) {
      await context.read<PatientCubit>().deletePatient(patient.id!);
    }
  }

  void _showPatientOptions(PatientEntity patient) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF18232C),
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
                  _openPatientForm(patient: patient);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _confirmDelete(patient);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientCubit, PatientState>(
      listener: (context, state) {
        if (state is PatientDeleted) {
          showSuccessSnackBar(context, 'Patient supprimé avec succès.');
        } else if (state is PatientError) {
          showErrorSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSearching
                ? TextField(
                    key: const ValueKey('searchField'),
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un patient',
                      border: InputBorder.none,
                    ),
                  )
                : const Text(
                    'Liste des patients',
                    key: ValueKey('title'),
                  ),
          ),
          actions: [
            IconButton(
              onPressed: _toggleSearch,
              icon: Icon(_isSearching ? Icons.close : Icons.search),
            ),
          ],
        ),
        body: BlocBuilder<PatientCubit, PatientState>(
          builder: (context, state) {
            if (state is PatientLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1D9E75)),
              );
            }

            if (state is PatientError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => context.read<PatientCubit>().loadPatients(),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is PatientListLoaded) {
              if (state.patients.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 72,
                        color: Colors.white38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun patient trouvé',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: state.patients.length,
                itemBuilder: (context, index) {
                  final patient = state.patients[index];
                  return PatientTile(
                    patient: patient,
                    onTap: () => _openPatientDetail(patient),
                    onLongPress: () => _showPatientOptions(patient),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF1D9E75),
          onPressed: _openPatientForm,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
