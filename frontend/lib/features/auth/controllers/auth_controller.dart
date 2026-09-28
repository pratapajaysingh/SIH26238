import 'package:flutter/material.dart';
import '../../../core/enums/auth_method_enum.dart';
import '../../../core/enums/role_enum.dart';
import '../../../core/utils/validators.dart';
import '../../../models/auth_session.dart';
import '../../../repositories/auth_repository.dart';

/// AuthController manages UI state for student registration and login flows.
/// Fully decouples UI presentation from backend API/mock communication.
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository {
    mobileController.addListener(_onInputChanged);
    aadhaarController.addListener(_onInputChanged);
  }

  // State Properties
  UserRole _selectedRole = UserRole.student;
  AuthMethod _selectedMethod = AuthMethod.mobile;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isOtpSent = false;
  AuthSession? _session;

  // Text Controllers
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Getters
  UserRole get selectedRole => _selectedRole;
  AuthMethod get selectedMethod => _selectedMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isOtpSent => _isOtpSent;
  AuthSession? get session => _session;
  bool get isAuthenticated => _session != null;

  bool get canContinue {
    if (_isLoading) return false;
    if (_selectedMethod == AuthMethod.mobile) {
      final text = mobileController.text.trim();
      return text.length == 10;
    } else {
      final text = aadhaarController.text.trim();
      return text.length == 12;
    }
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

  void setAuthMethod(AuthMethod method) {
    if (_selectedMethod == method) return;
    _selectedMethod = method;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Handles primary action on Continue button
  Future<bool> submitContinue() async {
    _errorMessage = null;
    _successMessage = null;

    if (_selectedMethod == AuthMethod.mobile) {
      final mobile = mobileController.text.trim();
      final validationError = Validators.validateMobile(mobile);
      if (validationError != null) {
        _errorMessage = validationError;
        notifyListeners();
        return false;
      }

      _setLoading(true);
      try {
        final response = await _authRepository.sendMobileOtp(mobile);
        _setLoading(false);

        if (response.success) {
          _isOtpSent = true;
          _successMessage = response.message;
          notifyListeners();
          return true;
        } else {
          _errorMessage = response.message;
          notifyListeners();
          return false;
        }
      } catch (e) {
        _setLoading(false);
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        notifyListeners();
        return false;
      }
    } else {
      final aadhaar = aadhaarController.text.trim();
      final validationError = Validators.validateAadhaar(aadhaar);
      if (validationError != null) {
        _errorMessage = validationError;
        notifyListeners();
        return false;
      }

      _setLoading(true);
      try {
        final response = await _authRepository.sendAadhaarOtp(aadhaar);
        _setLoading(false);

        if (response.success) {
          _isOtpSent = true;
          _successMessage = response.message;
          notifyListeners();
          return true;
        } else {
          _errorMessage = response.message;
          notifyListeners();
          return false;
        }
      } catch (e) {
        _setLoading(false);
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        notifyListeners();
        return false;
      }
    }
  }

  /// Verifies OTP code
  Future<bool> verifyOtp(String otp) async {
    final validationError = Validators.validateOtp(otp);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      if (_selectedMethod == AuthMethod.mobile) {
        final response = await _authRepository.verifyMobileOtp(
          mobileController.text.trim(),
          otp.trim(),
        );
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
      } else {
        final response = await _authRepository.verifyAadhaarOtp(
          aadhaarController.text.trim(),
          otp.trim(),
        );
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
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Initiates DigiLocker integration authentication
  Future<bool> loginWithDigiLocker() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await _authRepository.loginWithDigiLocker();
      _setLoading(false);

      if (response.success && response.data != null) {
        _session = response.data;
        _successMessage = response.message;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Initiates APAAR ID authentication
  Future<bool> loginWithApaar([String apaarId = '']) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await _authRepository.loginWithApaar(apaarId);
      _setLoading(false);

      if (response.success && response.data != null) {
        _session = response.data;
        _successMessage = response.message;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void resetOtpState() {
    _isOtpSent = false;
    otpController.clear();
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    mobileController.removeListener(_onInputChanged);
    aadhaarController.removeListener(_onInputChanged);
    mobileController.dispose();
    aadhaarController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
