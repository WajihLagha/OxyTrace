import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../../../shared/widgets/patient_tile.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../patient/data/datasources/patient_local_datasource.dart';
import '../cubit/patient_cubit.dart';
import '../cubit/patient_state.dart';
import 'patient_detail_screen.dart';
import 'patient_form_screen.dart';
import 'patient_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<int> _totalPatientsFuture;

  @override
  void initState() {
    super.initState();
    _refreshDashboard();
  }

  void _refreshDashboard() {
    _totalPatientsFuture = sl<PatientLocalDatasource>().getPatientsCount();
    context.read<PatientCubit>().loadPatients();
  }

  Future<void> _openPatientForm() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PatientFormScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(_refreshDashboard);
  }

  Future<void> _openPatientList({bool openSearch = false}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PatientListScreen(openSearch: openSearch),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(_refreshDashboard);
  }

  Future<void> _openPatientDetail(PatientState state, int index) async {
    if (state is! PatientListLoaded) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PatientDetailScreen(patient: state.patients[index]),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(_refreshDashboard);
  }

  void _logout() {
    context.read<AuthCubit>().reset();
    context.read<PatientCubit>().reset();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  int _recentCount(List patients) {
    final threshold = DateTime.now().subtract(const Duration(days: 7));
    return patients
        .where((patient) => patient.createdAt.isAfter(threshold))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IntubApp'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF1D9E75),
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<PatientCubit, PatientState>(
        builder: (context, state) {
          final recentCount = state is PatientListLoaded
              ? _recentCount(state.patients)
              : 0;
          final latestPatients = state is PatientListLoaded
              ? state.patients.take(5).toList()
              : const [];

          return RefreshIndicator(
            color: const Color(0xFF1D9E75),
            onRefresh: () async {
              setState(_refreshDashboard);
              await _totalPatientsFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<int>(
                        future: _totalPatientsFuture,
                        builder: (context, snapshot) {
                          return _StatCard(
                            label: 'Total patients',
                            value: snapshot.data?.toString() ?? '--',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        label: 'Dossiers récents',
                        value: recentCount.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.15,
                  children: [
                    _ActionCard(
                      icon: Icons.person_add_alt_1,
                      label: 'Nouveau patient',
                      onTap: _openPatientForm,
                    ),
                    _ActionCard(
                      icon: Icons.folder_copy_outlined,
                      label: 'Liste des patients',
                      onTap: _openPatientList,
                    ),
                    _ActionCard(
                      icon: Icons.search,
                      label: 'Rechercher',
                      onTap: () => _openPatientList(openSearch: true),
                    ),
                    _ActionCard(
                      icon: Icons.sync,
                      label: 'Synchronisation',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fonctionnalité à venir'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text(
                      'Derniers dossiers',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _openPatientList,
                      child: const Text('Voir tous'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state is PatientLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1D9E75),
                      ),
                    ),
                  )
                else if (state is PatientError)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Text(state.message),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => setState(_refreshDashboard),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                else if (latestPatients.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 48,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun patient enregistré pour le moment',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: List.generate(
                        latestPatients.length,
                        (index) => PatientTile(
                          patient: latestPatients[index],
                          onTap: () => _openPatientDetail(state, index),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: const Border(
          top: BorderSide(color: Color(0xFF1D9E75), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF1D9E75),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF1D9E75), size: 32),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
