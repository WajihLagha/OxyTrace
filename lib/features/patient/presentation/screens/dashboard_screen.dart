import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/patient_tile.dart';
import '../../../auth/presentation/screens/profile_screen.dart';
import '../../data/datasources/patient_local_datasource.dart';
import '../../domain/entities/patient_entity.dart';
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
  int _currentIndex = 0;
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

  int _recentCount(List<PatientEntity> patients) {
    final threshold = DateTime.now().subtract(const Duration(days: 7));
    return patients.where((patient) => patient.createdAt.isAfter(threshold)).length;
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

  Future<void> _openPatientDetail(PatientEntity patient) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PatientDetailScreen(patient: patient),
      ),
    );
    if (!mounted) {
      return;
    }
    setState(_refreshDashboard);
  }

  Widget _buildHomeTab() {
    return BlocBuilder<PatientCubit, PatientState>(
      builder: (context, state) {
        final recentCount =
            state is PatientListLoaded ? _recentCount(state.patients) : 0;
        final latestPatients = state is PatientListLoaded
            ? state.patients.take(5).toList()
            : <PatientEntity>[];

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            setState(_refreshDashboard);
            await _totalPatientsFuture;
          },
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
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
                    onTap: () => showInfoSnackBar(
                      context,
                      'Fonctionnalité à venir',
                    ),
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
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (state is PatientError)
                ErrorState(
                  message: state.message,
                  onRetry: () => setState(_refreshDashboard),
                )
              else if (latestPatients.isEmpty)
                const EmptyState(
                  icon: Icons.people_outline,
                  title: 'Aucun patient enregistré',
                  subtitle: 'Ajoutez un patient pour commencer.',
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: latestPatients
                        .map(
                          (patient) => PatientTile(
                            patient: patient,
                            onTap: () => _openPatientDetail(patient),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildHomeTab(),
      const PatientListScreen(showAppBar: false, showFab: false),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              AppAssets.logo,
              width: 32,
              height: 32,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.medical_services,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              AppStrings.appName,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(
              color: AppColors.surfaceVariant,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (value) => setState(() => _currentIndex = value),
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.muted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Patients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: const Border(
          top: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted),
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
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 32),
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
