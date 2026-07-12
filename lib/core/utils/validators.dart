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

  static String? tournamentName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Tournament name is required.';
    if (value.trim().length > 100) return 'Name must be at most 100 characters.';
    return null;
  }

  static String? description(String? value) {
    if (value != null && value.trim().length > 2000) {
      return 'Description must be at most 2000 characters.';
    }
    return null;
  }

  static String? maxTeams(String? value) {
    if (value == null || value.trim().isEmpty) return 'Max teams is required.';
    final n = int.tryParse(value.trim());
    if (n == null || n < 2 || n > 512) return 'Must be between 2 and 512.';
    return null;
  }

  static String? maxPlayersPerTeam(String? value) {
    if (value == null || value.trim().isEmpty) return 'Max players is required.';
    final n = int.tryParse(value.trim());
    if (n == null || n < 1 || n > 20) return 'Must be between 1 and 20.';
    return null;
  }

  static String? futureDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return 'Start date is required.';
    final dt = DateTime.tryParse(value.trim());
    if (dt == null) return 'Invalid date format.';
    if (!dt.isAfter(DateTime.now())) return 'Must be a future date and time.';
    return null;
  }

  static String? Function(String?) endDateAfterStart(String startValue) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return 'End date is required.';
      final end = DateTime.tryParse(value.trim());
      if (end == null) return 'Invalid date format.';
      final start = DateTime.tryParse(startValue.trim());
      if (start != null && !end.isAfter(start)) {
        return 'Must be after start date.';
      }
      return null;
    };
  }

  static String? Function(String?) registrationEndAfterStart(
      String? startValue) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return null;
      final end = DateTime.tryParse(value.trim());
      if (end == null) return 'Invalid date format.';
      if (startValue != null && startValue.trim().isNotEmpty) {
        final start = DateTime.tryParse(startValue.trim());
        if (start != null && !end.isAfter(start)) {
          return 'Must be after registration start.';
        }
      }
      return null;
    };
  }

  static String? rules(String? value) {
    if (value != null && value.trim().length > 5000) {
      return 'Rules must be at most 5000 characters.';
    }
    return null;
  }
}
