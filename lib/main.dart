import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:email_otp/email_otp.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/intubation/presentation/cubit/intubation_cubit.dart';
import 'features/patient/presentation/cubit/patient_cubit.dart';
import 'features/patient/presentation/screens/dashboard_screen.dart';
import 'features/patient/presentation/screens/patient_form_screen.dart';
import 'features/patient/presentation/screens/patient_list_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureEmailOtp();
  await initDependencies();
  runApp(const OxyTraceApp());
}

void _configureEmailOtp() {
  EmailOTP.config(
    appName: AppStrings.appName,
    otpType: OTPType.numeric,
    emailTheme: EmailTheme.v6,
    otpLength: 6,
    expiry: 300000,
  );

  const smtpHost = String.fromEnvironment('OXYTRACE_SMTP_HOST');
  const smtpUsername = String.fromEnvironment('OXYTRACE_SMTP_USERNAME');
  const smtpPassword = String.fromEnvironment('OXYTRACE_SMTP_PASSWORD');

  if (smtpHost.isEmpty || smtpUsername.isEmpty || smtpPassword.isEmpty) {
    return;
  }

  EmailOTP.setSMTP(
    host: smtpHost,
    emailPort: EmailPort.port587,
    secureType: SecureType.tls,
    username: smtpUsername,
    password: smtpPassword,
  );
}

class OxyTraceApp extends StatelessWidget {
  const OxyTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()..loadTheme()),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<PatientCubit>(create: (_) => sl<PatientCubit>()),
        BlocProvider<IntubationCubit>(create: (_) => sl<IntubationCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppStrings.appName,
            initialRoute: '/splash',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routes: {
              '/splash': (_) => const SplashScreen(),
              '/': (_) => const LoginScreen(),
              '/dashboard': (_) => const DashboardScreen(),
              '/patients': (_) => const PatientListScreen(),
              '/patient/new': (_) => const PatientFormScreen(),
            },
          );
        },
      ),
    );
  }
}
