import 'package:flutter_test/flutter_test.dart';
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

    test('Initial state is correct: Student role, empty state, no errors', () {
      expect(authController.selectedRole, UserRole.student);
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

    test('Validators correctly validate email addresses', () {
      expect(Validators.validateEmail(''), 'Please enter your email address');
      expect(Validators.validateEmail('invalid-email'), 'Please enter a valid email address');
      expect(Validators.validateEmail('student@'), 'Please enter a valid email address');
      expect(Validators.validateEmail('student@example.com'), isNull);
      expect(Validators.validateEmail('rameshwar.murmu@tribalsetu.gov.in'), isNull);
    });

    test('Validators correctly validate 6-digit OTP codes', () {
      expect(Validators.validateOtp(''), 'Please enter the 6-digit code');
      expect(Validators.validateOtp('123'), 'Code must be exactly 6 digits');
      expect(Validators.validateOtp('abcdef'), 'Code must be exactly 6 digits');
      expect(Validators.validateOtp('123456'), isNull);
    });

    test('Full email OTP authentication lifecycle against MockAuthRepository', () async {
      authController.emailController.text = 'student@example.com';
      final requestSuccess = await authController.requestOtp();

      expect(requestSuccess, true);
      expect(authController.isOtpSent, true);
      expect(authController.expiresIn, 300);
      expect(authController.errorMessage, isNull);

      final verifySuccess = await authController.verifyOtp('123456');
      expect(verifySuccess, true);
      expect(authController.isAuthenticated, true);
      expect(authController.session?.user.email, 'student@example.com');
      expect(authController.session?.user.role, UserRole.student);
    });

    test('MockAuthRepository rejects invalid OTP codes and only accepts 123456', () async {
      authController.emailController.text = 'student@example.com';
      await authController.requestOtp();

      final failWrongCode = await authController.verifyOtp('654321');
      expect(failWrongCode, false);
      expect(authController.isAuthenticated, false);
      expect(authController.errorMessage, 'Invalid or expired code.');

      final failRandomSixDigits = await authController.verifyOtp('999999');
      expect(failRandomSixDigits, false);
      expect(authController.isAuthenticated, false);
      expect(authController.errorMessage, 'Invalid or expired code.');

      final successFixedCode = await authController.verifyOtp('123456');
      expect(successFixedCode, true);
      expect(authController.isAuthenticated, true);
    });

    test('Logout action clears session credentials', () async {
      authController.emailController.text = 'student@example.com';
      await authController.requestOtp();
      await authController.verifyOtp('123456');
      expect(authController.isAuthenticated, true);

      await authController.logout();
      expect(authController.isAuthenticated, false);
      expect(authController.session, isNull);
    });
  });
}
