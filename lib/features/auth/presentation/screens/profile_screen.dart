import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/info_row.dart';
import '../../../patient/data/datasources/patient_local_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../cubit/auth_cubit.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;

  const ProfileScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserEntity? _user;
  bool _isLoading = true;
  String? _errorMessage;
  late Future<_ProfileStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await context.read<AuthCubit>().getCurrentUser();
      if (!mounted) {
        return;
      }
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Impossible de charger le profil.';
        _isLoading = false;
      });
    }
  }

  Future<_ProfileStats> _loadStats() async {
    final datasource = sl<PatientLocalDatasource>();
    final patients = await datasource.getPatientsCount();
    final intubations = await datasource.getIntubationsCount();
    return _ProfileStats(
      totalPatients: patients,
      totalIntubations: intubations,
    );
  }

  String _initials(UserEntity user) {
    final parts = user.fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return 'M';
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Se déconnecter',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      await context.read<AuthCubit>().logout();
      if (!mounted) {
        return;
      }
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: AppStrings.version,
      applicationIcon: Image.asset(
        AppAssets.logo,
        width: 48,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.medical_services,
          size: 40,
          color: AppColors.primary,
        ),
      ),
      children: const [
        Text(
          "Application mobile de gestion de l'intubation trachéale.\n"
          'Développée dans le cadre du cours Développement Mobile – FIGL2B.',
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: scheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.58),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: () {
          setState(() {
            _errorMessage = null;
            _isLoading = true;
            _statsFuture = _loadStats();
          });
          _loadUser();
        },
      );
    }

    final user = _user;
    if (user == null) {
      return ErrorState(
        message: 'Aucun utilisateur connecté.',
        onRetry: _loadUser,
      );
    }

    return FutureBuilder<_ProfileStats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return ErrorState(
            message: 'Impossible de charger les statistiques.',
            onRetry: () {
              setState(() {
                _statsFuture = _loadStats();
              });
            },
          );
        }

        final stats = snapshot.data!;
        final scheme = Theme.of(context).colorScheme;
        final muted = scheme.onSurface.withValues(alpha: 0.58);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: scheme.primary,
                      child: Text(
                        _initials(user),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.email,
                      style: TextStyle(color: muted),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: null,
                      child: const Text('Médecin'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _ProfileSection(
                title: 'Informations du compte',
                child: Column(
                  children: [
                    InfoRow(label: 'Nom complet', value: user.fullName),
                    InfoRow(label: 'Email', value: user.email),
                    const InfoRow(label: 'Rôle', value: 'Médecin'),
                    const InfoRow(label: 'Version', value: AppStrings.version),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _ProfileSection(
                title: 'Statistiques',
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        'Patients',
                        '${stats.totalPatients}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        "Dossiers d'intubation",
                        '${stats.totalIntubations}',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _ProfileSection(
                title: 'Paramètres',
                child: Column(
                  children: [
                    BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, themeMode) {
                        final isDark = themeMode == ThemeMode.dark;
                        return SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: Icon(
                            isDark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                          ),
                          title: const Text('Thème sombre'),
                          subtitle: Text(isDark ? 'Activé' : 'Désactivé'),
                          value: isDark,
                          onChanged: (value) =>
                              context.read<ThemeCubit>().setDarkMode(value),
                        );
                      },
                    ),
                    const ListTile(
                      leading: Icon(Icons.language),
                      title: Text('Langue'),
                      trailing: Text('Français'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('À propos'),
                      onTap: _showAbout,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Divider(color: scheme.secondaryContainer),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.danger),
                title: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: AppColors.danger),
                ),
                onTap: _confirmLogout,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: _buildBody(),
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Mon Profil'),
      ),
      body: body,
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _ProfileSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ProfileStats {
  final int totalPatients;
  final int totalIntubations;

  const _ProfileStats({
    required this.totalPatients,
    required this.totalIntubations,
  });
}
