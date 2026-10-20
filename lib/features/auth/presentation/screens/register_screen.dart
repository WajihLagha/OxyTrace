import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    final fullName = value?.trim() ?? '';
    if (fullName.isEmpty) {
      return 'Veuillez saisir votre nom complet.';
    }
    if (fullName.length < 2) {
      return 'Le nom complet doit contenir au moins 2 caractères.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value?.trim() ?? '';
    if (confirmPassword.isEmpty) {
      return 'Veuillez confirmer votre mot de passe.';
    }
    if (confirmPassword != _passwordController.text.trim()) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }

  void _submitRegister() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthCubit>().sendRegistrationOtp(
          _fullNameController.text,
          _emailController.text,
          _passwordController.text,
        );
  }

  void _submitOtp() {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      showErrorSnackBar(context, 'Veuillez saisir le code reçu par e-mail.');
      return;
    }

    context.read<AuthCubit>().verifyRegistrationOtp(otp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                showSuccessSnackBar(context, 'Compte vérifié avec succès.');
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
              } else if (state is AuthOtpSent && state.message != null) {
                showSuccessSnackBar(context, state.message!);
              } else if (state is AuthFailure) {
                showErrorSnackBar(context, state.message);
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              final isOtpStep = state is AuthOtpSent;
              final isVerifying = state is AuthOtpSent && state.isVerifying;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Image.asset(
                              AppAssets.logo,
                              width: 90,
                              height: 90,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.medical_services,
                                size: 80,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            isOtpStep
                                ? 'Vérifier votre e-mail'
                                : 'Créer un compte',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isOtpStep
                                ? 'Un code de vérification est nécessaire pour terminer.'
                                : 'Complétez les informations ci-dessous pour créer votre accès.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(height: 32),
                          if (!isOtpStep) ...[
                            AppTextField(
                              controller: _fullNameController,
                              label: 'Nom complet',
                              keyboardType: TextInputType.name,
                              validator: _validateFullName,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _emailController,
                              label: 'Adresse e-mail',
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _passwordController,
                              label: 'Mot de passe',
                              obscureText: true,
                              validator: Validators.validatePassword,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirmer le mot de passe',
                              obscureText: true,
                              validator: _validateConfirmPassword,
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              label: isLoading
                                  ? 'Envoi du code...'
                                  : 'Envoyer le code',
                              onPressed: isLoading ? null : _submitRegister,
                            ),
                          ] else ...[
                            _OtpVerificationCard(
                              email: state.email,
                              controller: _otpController,
                              errorMessage: state.errorMessage,
                              isLoading: isVerifying,
                              onVerify: _submitOtp,
                              onResend: isVerifying
                                  ? null
                                  : context
                                      .read<AuthCubit>()
                                      .resendRegistrationOtp,
                              onEditEmail: isVerifying
                                  ? null
                                  : () {
                                      _otpController.clear();
                                      context.read<AuthCubit>().reset();
                                    },
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: isLoading || isVerifying
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Déjà un compte ? Se connecter'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OtpVerificationCard extends StatelessWidget {
  final String email;
  final TextEditingController controller;
  final String? errorMessage;
  final bool isLoading;
  final VoidCallback onVerify;
  final VoidCallback? onResend;
  final VoidCallback? onEditEmail;

  const _OtpVerificationCard({
    required this.email,
    required this.controller,
    required this.errorMessage,
    required this.isLoading,
    required this.onVerify,
    required this.onResend,
    required this.onEditEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.primary,
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            'Vérification e-mail',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Entrez le code envoyé à $email pour activer votre compte.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: controller,
            label: 'Code OTP',
            keyboardType: TextInputType.number,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: const TextStyle(color: AppColors.danger),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 18),
          AppButton(
            label: isLoading ? 'Vérification...' : 'Vérifier et continuer',
            onPressed: isLoading ? null : onVerify,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onResend,
            child: const Text('Renvoyer le code'),
          ),
          TextButton(
            onPressed: onEditEmail,
            child: const Text("Changer l'adresse e-mail"),
          ),
        ],
      ),
    );
  }
}
