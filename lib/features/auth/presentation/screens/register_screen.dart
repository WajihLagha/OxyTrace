import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

    context.read<AuthCubit>().register(
      _fullNameController.text,
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    showSuccessSnackBar(
                      context,
                      'Compte créé avec succès. Vous pouvez maintenant vous connecter.',
                    );
                    Navigator.of(context).pop();
                  } else if (state is AuthFailure) {
                    showErrorSnackBar(context, state.message);
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Créer un compte',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complétez les informations ci-dessous pour créer votre accès.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),
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
                          label: "S'inscrire",
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _submitRegister,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Déjà un compte ? Se connecter'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
