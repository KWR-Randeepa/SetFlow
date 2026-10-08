import 'dart:convert';

abstract final class Validators {
  static String? name(String? value) {
    final name = (value ?? '').trim();
    if (name.isEmpty) return 'Enter your full name.';
    if (name.length > 80) return 'Use 80 characters or fewer.';
    return null;
  }

  static String? email(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Enter your email address.';
    if (email.length > 254 ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  // Six characters matches the supplied university prototype.
  // bcrypt processes at most 72 bytes; reject longer inputs, never truncate.
  static String? password(String? value) {
    final password = value ?? '';
    if (password.trim().isEmpty || password.runes.length < 6) {
      return 'Use at least 6 characters.';
    }
    if (utf8.encode(password).length > 72) return 'Use at most 72 UTF-8 bytes.';
    return null;
  }

  static String? confirmPassword(String? value, String password) =>
      value == password ? null : 'Passwords do not match.';
}