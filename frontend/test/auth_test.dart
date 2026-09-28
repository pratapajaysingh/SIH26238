import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/core/enums/auth_method_enum.dart';
import 'package:tribalsetu/core/enums/role_enum.dart';
import 'package:tribalsetu/core/utils/validators.dart';
import 'package:tribalsetu/features/auth/controllers/auth_controller.dart';
import 'package:tribalsetu/repositories/mock_auth_repository.dart';

void main() {
  group('Auth Unit & State Tests', () {
    late MockAuthRepository mockRepo;
    late AuthController authController;

    setUp(() {
      mockRepo = MockAuthRepository();
      authController = AuthController(authRepository: mockRepo);
    });

    tearDown(() {
      authController.dispose();
    });

    test('Initial state is correct: Student role, Mobile auth method, no errors', () {
      expect(authController.selectedRole, UserRole.student);
      expect(authController.selectedMethod, AuthMethod.mobile);
      expect(authController.isLoading, false);
      expect(authController.errorMessage, isNull);
      expect(authController.isOtpSent, false);
      expect(authController.isAuthenticated, false);
    });

    test('Role switching updates state properly', () {
      authController.setRole(UserRole.admin);
      expect(authController.selectedRole, UserRole.admin);

      authController.setRole(UserRole.institute);
      expect(authController.selectedRole, UserRole.institute);

      authController.setRole(UserRole.student);
      expect(authController.selectedRole, UserRole.student);
    });

    test('Auth method switching works properly', () {
      authController.setAuthMethod(AuthMethod.aadhaar);
      expect(authController.selectedMethod, AuthMethod.aadhaar);

      authController.setAuthMethod(AuthMethod.mobile);
      expect(authController.selectedMethod, AuthMethod.mobile);
    });

    test('Validators correctly validate Indian mobile numbers', () {
      expect(Validators.validateMobile(''), 'Please enter your mobile number');
      expect(Validators.validateMobile('12345'), 'Mobile number must be 10 digits');
      expect(Validators.validateMobile('1234567890'), 'Please enter a valid mobile number starting with 6-9');
      expect(Validators.validateMobile('9876543210'), isNull);
      expect(Validators.validateMobile('8765432109'), isNull);
      expect(Validators.validateMobile('7654321098'), isNull);
      expect(Validators.validateMobile('6543210987'), isNull);
    });

    test('Validators correctly validate 12-digit Aadhaar numbers', () {
      expect(Validators.validateAadhaar(''), 'Please enter your Aadhaar number');
      expect(Validators.validateAadhaar('123'), 'Aadhaar number must be 12 digits');
      expect(Validators.validateAadhaar('123456789012'), isNull);
    });

    test('Full mobile OTP authentication lifecycle against MockAuthRepository', () async {
      authController.mobileController.text = '9876543210';
      final continueSuccess = await authController.submitContinue();

      expect(continueSuccess, true);
      expect(authController.isOtpSent, true);
      expect(authController.errorMessage, isNull);

      final verifySuccess = await authController.verifyOtp('123456');
      expect(verifySuccess, true);
      expect(authController.isAuthenticated, true);
      expect(authController.session?.user.name, 'Rameshwar Murmu');
      expect(authController.session?.user.role, UserRole.student);
    });

    test('DigiLocker direct integration handshake completes session', () async {
      final success = await authController.loginWithDigiLocker();
      expect(success, true);
      expect(authController.isAuthenticated, true);
      expect(authController.session?.user.isAadhaarVerified, true);
    });

    test('APAAR ID verification sets authenticated session', () async {
      final success = await authController.loginWithApaar('APAAR-2026-9921');
      expect(success, true);
      expect(authController.isAuthenticated, true);
      expect(authController.session?.user.apaarId, 'APAAR-2026-9921');
    });
  });
}
