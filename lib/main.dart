import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/patient/presentation/cubit/patient_cubit.dart';
import 'features/patient/presentation/screens/dashboard_screen.dart';
import 'features/patient/presentation/screens/patient_form_screen.dart';
import 'features/patient/presentation/screens/patient_list_screen.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const OxyTraceApp());
}

class OxyTraceApp extends StatelessWidget {
  const OxyTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1D9E75);
    final baseTheme = ThemeData.dark();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<PatientCubit>(create: (_) => sl<PatientCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OxyTrace',
        theme: baseTheme.copyWith(
          primaryColor: primaryColor,
          colorScheme: baseTheme.colorScheme.copyWith(primary: primaryColor),
          scaffoldBackgroundColor: const Color(0xFF101820),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF101820),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: primaryColor, width: 1.4),
            ),
          ),
        ),
        routes: {
          '/': (_) => const LoginScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/patients': (_) => const PatientListScreen(),
          '/patient/new': (_) => const PatientFormScreen(),
        },
      ),
    );
  }
}
