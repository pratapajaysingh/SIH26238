import '../constants/api_constants.dart';
import '../network/api_client.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/api_auth_repository.dart';
import '../../repositories/mock_auth_repository.dart';
import '../../repositories/student_repository.dart';
import '../../repositories/api_student_repository.dart';
import '../../repositories/mock_student_repository.dart';
import '../../repositories/scholarship_repository.dart';
import '../../repositories/api_scholarship_repository.dart';
import '../../repositories/mock_scholarship_repository.dart';
import '../../repositories/application_repository.dart';
import '../../repositories/api_application_repository.dart';
import '../../repositories/mock_application_repository.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/api_notification_repository.dart';
import '../../repositories/mock_notification_repository.dart';
import '../../repositories/document_repository.dart';
import '../../repositories/api_document_repository.dart';
import '../../repositories/mock_document_repository.dart';
import '../../repositories/profile_repository.dart';
import '../../repositories/api_profile_repository.dart';
import '../../repositories/mock_profile_repository.dart';
import '../../repositories/jago_repository.dart';
import '../../repositories/api_jago_repository.dart';
import '../../repositories/mock_jago_repository.dart';
import '../../repositories/eligibility_repository.dart';
import '../../repositories/api_eligibility_repository.dart';
import '../../repositories/mock_eligibility_repository.dart';
import '../../repositories/verification_repository.dart';
import '../../repositories/api_verification_repository.dart';
import '../../repositories/mock_verification_repository.dart';
import '../../repositories/payment_repository.dart';
import '../../repositories/api_payment_repository.dart';
import '../../repositories/mock_payment_repository.dart';

/// ServiceLocator provides all repository instances centrally.
///
/// ┌──────────────────────────────────────────────────────────┐
/// │  TO CONNECT TO REAL BACKEND:                             │
/// │                                                          │
/// │  1. Change [useMock] to false                            │
/// │  2. Set [baseUrl] to your backend URL                    │
/// │  3. That's it. All screens automatically use real APIs.  │
/// └──────────────────────────────────────────────────────────┘
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator _instance = ServiceLocator._();
  static ServiceLocator get instance => _instance;

  // ── CONFIGURATION ─────────────────────────────────────────
  //
  // Toggle this single flag to switch the ENTIRE app between
  // mock data (for development/testing) and real API calls.
  //
  // Can also be overridden via --dart-define:
  //   flutter run --dart-define=USE_MOCK=false
  //   flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8000
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: ApiConstants.baseUrl,
  );

  // ── SHARED API CLIENT ─────────────────────────────────────
  late final ApiClient _apiClient = ApiClient(baseUrl: baseUrl);

  /// Access the shared ApiClient (e.g., to set auth token after login).
  ApiClient get apiClient => _apiClient;

  /// Set the bearer token after successful authentication.
  void setAuthToken(String? token) {
    _apiClient.setAuthToken(token);
  }

  // ── REPOSITORIES ──────────────────────────────────────────

  AuthRepository get authRepository => useMock
      ? MockAuthRepository()
      : ApiAuthRepository(apiClient: _apiClient);

  StudentRepository get studentRepository => useMock
      ? MockStudentRepository()
      : ApiStudentRepository(apiClient: _apiClient);

  ScholarshipRepository get scholarshipRepository => useMock
      ? MockScholarshipRepository()
      : ApiScholarshipRepository(apiClient: _apiClient);

  ApplicationRepository get applicationRepository => useMock
      ? MockApplicationRepository()
      : ApiApplicationRepository(apiClient: _apiClient);

  NotificationRepository get notificationRepository => useMock
      ? MockNotificationRepository()
      : ApiNotificationRepository(apiClient: _apiClient);

  DocumentRepository get documentRepository => useMock
      ? MockDocumentRepository()
      : ApiDocumentRepository(apiClient: _apiClient);

  ProfileRepository get profileRepository => useMock
      ? MockProfileRepository()
      : ApiProfileRepository(apiClient: _apiClient);

  JagoRepository get jagoRepository => useMock
      ? MockJagoRepository()
      : ApiJagoRepository(apiClient: _apiClient);

  EligibilityRepository get eligibilityRepository => useMock
      ? MockEligibilityRepository()
      : ApiEligibilityRepository(apiClient: _apiClient);

  VerificationRepository get verificationRepository => useMock
      ? MockVerificationRepository()
      : ApiVerificationRepository(apiClient: _apiClient);

  PaymentRepository get paymentRepository => useMock
      ? MockPaymentRepository()
      : ApiPaymentRepository(apiClient: _apiClient);
}
