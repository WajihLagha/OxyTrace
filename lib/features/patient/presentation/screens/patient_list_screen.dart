import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/patient_tile.dart';
import '../../domain/entities/patient_entity.dart';
import '../cubit/patient_cubit.dart';
import '../cubit/patient_state.dart';
import 'patient_detail_screen.dart';
import 'patient_form_screen.dart';

class PatientListScreen extends StatefulWidget {
  final bool openSearch;
  final bool showAppBar;
  final bool showFab;

  const PatientListScreen({
    super.key,
    this.openSearch = false,
    this.showAppBar = true,
    this.showFab = true,
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
    final requestId = _searchRequestId;
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (!mounted || requestId != _searchRequestId) {
        return;
      }
      if (query.trim().isEmpty) {
        context.read<PatientCubit>().loadPatients();
      } else {
        context.read<PatientCubit>().searchPatients(query);
      }
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
                style: TextStyle(color: AppColors.danger),
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
      backgroundColor: AppColors.surface,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openPatientForm(patient: patient);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.danger,
                ),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDelete(patient);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListContent() {
    return BlocBuilder<PatientCubit, PatientState>(
      builder: (context, state) {
        if (state is PatientLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        }

        if (state is PatientError) {
          return ErrorState(
            message: state.message,
            onRetry: () => context.read<PatientCubit>().loadPatients(),
          );
        }

        if (state is PatientListLoaded) {
          if (state.patients.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              title: 'Aucun patient trouvé',
              subtitle: 'Ajoutez un patient pour commencer.',
              action: widget.showFab
                  ? OutlinedButton.icon(
                      onPressed: _openPatientForm,
                      icon: const Icon(Icons.add),
                      label: const Text('Nouveau patient'),
                    )
                  : null,
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: _buildListContent(),
    );

    if (!widget.showAppBar && !widget.showFab) {
      return content;
    }

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
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
            )
          : null,
      body: content,
      floatingActionButton: widget.showFab
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _openPatientForm,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
