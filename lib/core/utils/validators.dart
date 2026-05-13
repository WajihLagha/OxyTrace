class Validators {
  Validators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Veuillez saisir votre adresse e-mail.';
    }

    if (!_emailRegExp.hasMatch(email)) {
      return 'Veuillez saisir une adresse e-mail valide.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    final password = value?.trim() ?? '';

    if (password.isEmpty) {
      return 'Veuillez saisir votre mot de passe.';
    }

    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    }

    return null;
  }
}
