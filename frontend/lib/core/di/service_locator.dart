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

/// ServiceLocator provides centralized access to all repository instances.
///
/// Supports seamless switching between mock mode and the real FastAPI backend via:
/// - flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://localhost:8000
/// - ServiceLocator.useMockMode = false (programmatic)
class ServiceLocator {
  ServiceLocator._() {
    _initApiClient();
  }

  static final ServiceLocator _instance = ServiceLocator._();
  static ServiceLocator get instance => _instance;

  // ── CONFIGURATION ─────────────────────────────────────────
  static const bool _envUseMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  static bool _overrideUseMock = _envUseMock;

  /// Dynamic getter for mock status.
  static bool get useMock => _overrideUseMock;

  /// Allows runtime toggling between mock and real backend.
  static set useMockMode(bool value) {
    _overrideUseMock = value;
  }

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: ApiConstants.baseUrl,
  );

  // ── SHARED API CLIENT ─────────────────────────────────────
  late final ApiClient _apiClient = ApiClient(baseUrl: baseUrl);

  void _initApiClient() {
    _apiClient.onUnauthorized = () {
      // 401 Unauthorized handling: reset active session & bearer token
      _apiAuthRepository.logout();
    };
  }

  /// Access the shared ApiClient.
  ApiClient get apiClient => _apiClient;

  /// Set the bearer token on the shared ApiClient.
  void setAuthToken(String? token) {
    _apiClient.setAuthToken(token);
  }

  // ── SINGLETON REPOSITORY INSTANCES ────────────────────────
  late final MockAuthRepository _mockAuthRepository = MockAuthRepository();
  late final ApiAuthRepository _apiAuthRepository = ApiAuthRepository(apiClient: _apiClient);

  late final MockStudentRepository _mockStudentRepository = MockStudentRepository();
  late final ApiStudentRepository _apiStudentRepository = ApiStudentRepository(apiClient: _apiClient);

  late final MockScholarshipRepository _mockScholarshipRepository = MockScholarshipRepository();
  late final ApiScholarshipRepository _apiScholarshipRepository = ApiScholarshipRepository(apiClient: _apiClient);

  late final MockApplicationRepository _mockApplicationRepository = MockApplicationRepository();
  late final ApiApplicationRepository _apiApplicationRepository = ApiApplicationRepository(apiClient: _apiClient);

  late final MockNotificationRepository _mockNotificationRepository = MockNotificationRepository();
  late final ApiNotificationRepository _apiNotificationRepository = ApiNotificationRepository(apiClient: _apiClient);

  late final MockDocumentRepository _mockDocumentRepository = MockDocumentRepository();
  late final ApiDocumentRepository _apiDocumentRepository = ApiDocumentRepository(apiClient: _apiClient);

  late final MockProfileRepository _mockProfileRepository = MockProfileRepository();
  late final ApiProfileRepository _apiProfileRepository = ApiProfileRepository(apiClient: _apiClient);

  late final MockJagoRepository _mockJagoRepository = MockJagoRepository();
  late final ApiJagoRepository _apiJagoRepository = ApiJagoRepository(apiClient: _apiClient);

  late final MockEligibilityRepository _mockEligibilityRepository = MockEligibilityRepository();
  late final ApiEligibilityRepository _apiEligibilityRepository = ApiEligibilityRepository(apiClient: _apiClient);

  late final MockVerificationRepository _mockVerificationRepository = MockVerificationRepository();
  late final ApiVerificationRepository _apiVerificationRepository = ApiVerificationRepository(apiClient: _apiClient);

  late final MockPaymentRepository _mockPaymentRepository = MockPaymentRepository();
  late final ApiPaymentRepository _apiPaymentRepository = ApiPaymentRepository(apiClient: _apiClient);

  // ── REPOSITORY GETTERS ────────────────────────────────────
  AuthRepository get authRepository => useMock ? _mockAuthRepository : _apiAuthRepository;
  StudentRepository get studentRepository => useMock ? _mockStudentRepository : _apiStudentRepository;
  ScholarshipRepository get scholarshipRepository => useMock ? _mockScholarshipRepository : _apiScholarshipRepository;
  ApplicationRepository get applicationRepository => useMock ? _mockApplicationRepository : _apiApplicationRepository;
  NotificationRepository get notificationRepository => useMock ? _mockNotificationRepository : _apiNotificationRepository;
  DocumentRepository get documentRepository => useMock ? _mockDocumentRepository : _apiDocumentRepository;
  ProfileRepository get profileRepository => useMock ? _mockProfileRepository : _apiProfileRepository;
  JagoRepository get jagoRepository => useMock ? _mockJagoRepository : _apiJagoRepository;
  EligibilityRepository get eligibilityRepository => useMock ? _mockEligibilityRepository : _apiEligibilityRepository;
  VerificationRepository get verificationRepository => useMock ? _mockVerificationRepository : _apiVerificationRepository;
  PaymentRepository get paymentRepository => useMock ? _mockPaymentRepository : _apiPaymentRepository;
}
