abstract final class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required.';
    return null;
  }
  static String? emailOrUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email or username is required.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required.';
    if (value.trim().length > 100) return 'Name must be at most 100 characters.';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required.';
    if (value.trim().length > 50) return 'Username must be at most 50 characters.';
    final valid = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!valid.hasMatch(value.trim())) return 'Only letters, numbers, _ and - allowed.';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final valid = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
    if (!valid.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) return 'Please confirm your password.';
      if (value != password) return 'Passwords do not match.';
      return null;
    };
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'OTP is required.';
    if (value.trim().length != 6) return 'OTP must be 6 digits.';
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) return 'OTP must contain only digits.';
    return null;
  }
}
