import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navbar_router/navbar_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/patient_tile.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/screens/profile_screen.dart';
import '../../../bmi/presentation/screens/bmi_calculator_screen.dart';
import '../../data/datasources/patient_local_datasource.dart';
import '../../data/services/patient_sync_service.dart';
import '../../domain/entities/patient_entity.dart';
import '../cubit/dashboard_nav_cubit.dart';
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
  late final DashboardNavCubit _navCubit;
  late final PatientSyncService _syncService;
  late Future<int> _totalPatientsFuture;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _navCubit = DashboardNavCubit();
    _syncService = PatientSyncService(
      localDatasource: sl<PatientLocalDatasource>(),
    );
    _refreshDashboard();
  }

  @override
  void dispose() {
    _navCubit.close();
    super.dispose();
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

  Future<void> _logout() async {
    await context.read<AuthCubit>().logout();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<void> _syncPatients() async {
    if (_isSyncing) {
      return;
    }

    setState(() => _isSyncing = true);

    try {
      final result = await _syncService.syncPendingPatients();
      if (!mounted) {
        return;
      }

      final message = result.pendingBeforeSync == 0
          ? 'Aucun dossier en attente de synchronisation.'
          : '${result.syncedCount} dossier(s) synchronisé(s).';
      showSuccessSnackBar(context, message);
      setState(_refreshDashboard);
    } on PatientSyncException catch (error) {
      if (mounted) {
        showErrorSnackBar(context, error.message);
      }
    } catch (_) {
      if (mounted) {
        showErrorSnackBar(
          context,
          'La synchronisation a échoué. Veuillez réessayer.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Widget _buildHomeTab() {
    final colors = AppColors.of(context);
    return BlocBuilder<PatientCubit, PatientState>(
      builder: (context, state) {
        final recentCount =
            state is PatientListLoaded ? _recentCount(state.patients) : 0;
        final latestPatients = state is PatientListLoaded
            ? state.patients.take(5).toList()
            : <PatientEntity>[];
        final pendingSyncCount = state is PatientListLoaded
            ? state.patients.where((patient) => !patient.isSynced).length
            : 0;
        final syncedCount = state is PatientListLoaded
            ? state.patients.where((patient) => patient.isSynced).length
            : 0;

        return RefreshIndicator(
          color: colors.primary,
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
                  _SyncActionCard(
                    pendingCount: pendingSyncCount,
                    syncedCount: syncedCount,
                    isLoading: _isSyncing,
                    onTap: _syncPatients,
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
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: CircularProgressIndicator(
                      color: colors.primary,
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
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: latestPatients
                        .map(
                          (patient) => PatientTile(
                            patient: patient,
                            showSyncStatus: true,
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
    final colors = AppColors.of(context);
    final navItems = [
      NavbarItem(
        Icons.home_outlined,
        'Accueil',
        backgroundColor: colors.surface,
        selectedIcon: Icon(Icons.home, color: colors.primary, size: 26),
      ),
      NavbarItem(
        Icons.people_outline,
        'Patients',
        backgroundColor: colors.surface,
        selectedIcon: Icon(Icons.people, color: colors.primary, size: 26),
      ),
      NavbarItem(
        Icons.monitor_weight_outlined,
        'BMI',
        backgroundColor: colors.surface,
        selectedIcon: Icon(
          Icons.monitor_weight,
          color: colors.primary,
          size: 26,
        ),
      ),
      NavbarItem(
        Icons.person_outline,
        'Profil',
        backgroundColor: colors.surface,
        selectedIcon: Icon(Icons.person, color: colors.primary, size: 26),
      ),
    ];

    return BlocProvider<DashboardNavCubit>.value(
      value: _navCubit,
      child: BlocBuilder<DashboardNavCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Image.asset(
                    AppAssets.logo,
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.medical_services,
                      size: 28,
                      color: colors.primary,
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
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  tooltip: 'Se déconnecter',
                ),
              ],
            ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: NavbarRouter(
                initialIndex: currentIndex,
                type: NavbarType.notched,
                onChanged: (index) =>
                    context.read<DashboardNavCubit>().selectTab(index),
                errorBuilder: (_) => const Center(
                  child: Text('Page introuvable'),
                ),
                decoration: NotchedDecoration(
                  backgroundColor: colors.surface,
                  selectedIconColor: colors.primary,
                  unselectedIconColor: colors.muted,
                  unselectedLabelColor: colors.muted,
                  elevation: 8,
                ),
                destinations: [
                  DestinationRouter(
                    navbarItem: navItems[0],
                    destinations: [
                      Destination(route: '/', widget: _buildHomeTab()),
                    ],
                    initialRoute: '/',
                  ),
                  DestinationRouter(
                    navbarItem: navItems[1],
                    destinations: [
                      Destination(
                        route: '/',
                        widget: PatientListScreen(
                          showAppBar: false,
                          showFab: false,
                        ),
                      ),
                    ],
                    initialRoute: '/',
                  ),
                  DestinationRouter(
                    navbarItem: navItems[2],
                    destinations: [
                      Destination(
                        route: '/',
                        widget: const BmiCalculatorScreen(),
                      ),
                    ],
                    initialRoute: '/',
                  ),
                  DestinationRouter(
                    navbarItem: navItems[3],
                    destinations: [
                      Destination(
                        route: '/',
                        widget: ProfileScreen(embedded: true),
                      ),
                    ],
                    initialRoute: '/',
                  ),
                ],
              ),
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
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          top: BorderSide(color: colors.primary, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: colors.muted),
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
    final colors = AppColors.of(context);
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colors.primary, size: 32),
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

class _SyncActionCard extends StatelessWidget {
  final int pendingCount;
  final int syncedCount;
  final bool isLoading;
  final VoidCallback onTap;

  const _SyncActionCard({
    required this.pendingCount,
    required this.syncedCount,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  isLoading
                      ? SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            color: colors.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(Icons.sync, color: colors.primary, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Synchronisation',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SyncCountLine(
                label: 'En attente',
                value: pendingCount,
                color: colors.warning,
              ),
              const SizedBox(height: 6),
              _SyncCountLine(
                label: 'Synchronisé',
                value: syncedCount,
                color: colors.success,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncCountLine extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SyncCountLine({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.muted, fontSize: 12),
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
