import 'package:flutter/material.dart';
import '../../../core/enums/role_enum.dart';
import '../../../core/utils/validators.dart';
import '../../../models/auth_session.dart';
import '../../../repositories/auth_repository.dart';

/// AuthController manages UI state for student login and OTP verification flows.
/// Fully decoupled from backend API/mock communication.
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthController({
    required AuthRepository authRepository,
    AuthSession? initialSession,
  })  : _authRepository = authRepository,
        _session = initialSession {
    emailController.addListener(_onInputChanged);
    otpController.addListener(_onInputChanged);
  }

  // State Properties
  UserRole _selectedRole = UserRole.student;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isOtpSent = false;
  int _expiresIn = 300;
  int _retryAfterSeconds = 0;
  AuthSession? _session;

  // Text Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Getters
  UserRole get selectedRole => _selectedRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isOtpSent => _isOtpSent;
  int get expiresIn => _expiresIn;
  int get retryAfterSeconds => _retryAfterSeconds;
  AuthSession? get session => _session;
  bool get isAuthenticated => _session != null;

  bool get canContinue {
    if (_isLoading) return false;
    final text = emailController.text.trim();
    return text.isNotEmpty && text.contains('@');
  }

  void _onInputChanged() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void setRole(UserRole role) {
    if (_selectedRole == role) return;
    _selectedRole = role;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sends OTP to the provided email address (Step 1).
  Future<bool> submitContinue() async => requestOtp();

  /// Requests a one-time passcode for the email in [emailController].
  Future<bool> requestOtp() async {
    _errorMessage = null;
    _successMessage = null;

    final email = emailController.text.trim();
    final validationError = Validators.validateEmail(email);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final response = await _authRepository.requestOtp(email);
      _setLoading(false);

      if (response.success) {
        _isOtpSent = true;
        _expiresIn = response.data?.expiresIn ?? 300;
        _successMessage = response.message;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        if (response.data != null && response.data!.expiresIn > 0) {
          _retryAfterSeconds = response.data!.expiresIn;
        }
        notifyListeners();
        return false;
      }
    } catch (_) {
      _setLoading(false);
      _errorMessage = 'Unable to connect to server. Please check your internet connection.';
      notifyListeners();
      return false;
    }
  }

  /// Verifies the OTP code for the email in [emailController] (Step 2).
  Future<bool> verifyOtp(String otp) async {
    final validationError = Validators.validateOtp(otp);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final email = emailController.text.trim();
      final response = await _authRepository.verifyOtp(email, otp.trim());
      _setLoading(false);

      if (response.success && response.data != null) {
        _session = response.data;
        _isOtpSent = false;
        _successMessage = response.message;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (_) {
      _setLoading(false);
      _errorMessage = 'Unable to connect to server. Please check your internet connection.';
      notifyListeners();
      return false;
    }
  }

  /// Resends the OTP code to the current email.
  Future<bool> resendOtp() async {
    return requestOtp();
  }

  /// Returns from Step 2 to Step 1 to allow editing the email address.
  void resetOtpState() {
    _isOtpSent = false;
    otpController.clear();
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Logs out the active user, clearing persisted tokens and session.
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.logout();
    } finally {
      _session = null;
      _isOtpSent = false;
      emailController.clear();
      otpController.clear();
      _errorMessage = null;
      _successMessage = null;
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.removeListener(_onInputChanged);
    otpController.removeListener(_onInputChanged);
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
