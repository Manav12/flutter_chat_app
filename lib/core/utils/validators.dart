class Validators {
  const Validators._();

  static final _emailRegex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(trimmed)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    // Firebase itself won't accept a password shorter than 6 characters,
    // so we check for that here too instead of making up our own rule.
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Name is required';
    if (trimmed.length < 2) return 'Name must be at least 2 characters';
    return null;
  }
}
