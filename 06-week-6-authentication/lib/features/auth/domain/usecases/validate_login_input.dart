class ValidateLoginInput {
  const ValidateLoginInput();

  static const int minPasswordLength = 6;
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email tidak boleh kosong';
    if (!_emailRegex.hasMatch(v)) return 'Format email tidak valid';
    return null;
  }

  String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password tidak boleh kosong';
    if (v.length < minPasswordLength) {
      return 'Password minimal $minPasswordLength karakter';
    }
    return null;
  }
}
