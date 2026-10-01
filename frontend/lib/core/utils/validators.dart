/// Form and field validators for TribalSetu authentication and profile data.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );
  static final RegExp _otpRegex = RegExp(r'^\d{6}$');

  /// Validates email address format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final clean = value.trim();
    if (!_emailRegex.hasMatch(clean)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates 6-digit OTP code (must be exactly 6 numeric digits)
  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the 6-digit code';
    }
    final clean = value.trim();
    if (clean.length != 6 || !_otpRegex.hasMatch(clean)) {
      return 'Code must be exactly 6 digits';
    }
    return null;
  }
}
