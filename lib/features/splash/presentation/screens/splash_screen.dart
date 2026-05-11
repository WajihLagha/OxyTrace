import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!mounted) {
      return;
    }

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard');
      return;
    }

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SplashLogo(),
                SizedBox(height: 24),
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  AppStrings.appSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
                SizedBox(height: 48),
                CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
                SizedBox(height: 16),
                Text(
                  'Version ${AppStrings.version}',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
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

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logo,
      width: 120,
      height: 120,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.medical_services,
        size: 80,
        color: AppColors.primary,
      ),
    );
  }
}
