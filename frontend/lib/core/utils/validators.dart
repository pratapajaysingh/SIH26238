/// Form and field validators for TribalSetu authentication and profile data.
class Validators {
  Validators._();

  static final RegExp _mobileRegex = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _aadhaarRegex = RegExp(r'^\d{12}$');
  static final RegExp _otpRegex = RegExp(r'^\d{6}$');

  /// Validates 10-digit Indian mobile number
  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your mobile number';
    }
    final clean = value.replaceAll(RegExp(r'\s+'), '');
    if (clean.length != 10) {
      return 'Mobile number must be 10 digits';
    }
    if (!_mobileRegex.hasMatch(clean)) {
      return 'Please enter a valid mobile number starting with 6-9';
    }
    return null;
  }

  /// Validates 12-digit Aadhaar number
  static String? validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your Aadhaar number';
    }
    final clean = value.replaceAll(RegExp(r'\s+'), '');
    if (clean.length != 12) {
      return 'Aadhaar number must be 12 digits';
    }
    if (!_aadhaarRegex.hasMatch(clean)) {
      return 'Aadhaar must contain only digits';
    }
    return null;
  }

  /// Validates 6-digit OTP
  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the 6-digit OTP';
    }
    final clean = value.replaceAll(RegExp(r'\s+'), '');
    if (clean.length != 6 || !_otpRegex.hasMatch(clean)) {
      return 'OTP must be exactly 6 digits';
    }
    return null;
  }
}
