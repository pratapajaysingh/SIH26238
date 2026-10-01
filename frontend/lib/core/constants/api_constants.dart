/// ApiConstants defines locked endpoint paths conforming to the authoritative FastAPI backend.
class ApiConstants {
  ApiConstants._();

  // Base URL (configured via environment in production)
  // Defaults to http://localhost:8000 for local development (use http://10.0.2.2:8000 for Android emulator)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  static const String apiVersion = '/api/v1';

  // Auth endpoints (live OTP authentication contract)
  static const String authOtpRequest = '$apiVersion/auth/otp/request';
  static const String authOtpVerify = '$apiVersion/auth/otp/verify';

  // Student endpoints
  static const String studentsMe = '$apiVersion/students/me';
  static const String students = '$apiVersion/students';
  static String studentDigiLockerDocuments(String studentId) => '$apiVersion/students/$studentId/digilocker/documents';
  static String studentDigiLockerImport(String studentId) => '$apiVersion/students/$studentId/digilocker/documents/import';

  // Scholarships
  static const String scholarships = '$apiVersion/scholarships';

  // Eligibility
  // Eligibility & Conflict Check
  static const String eligibilityCheck = '$apiVersion/eligibility/check';
  static const String eligibilityConflictCheck = '$apiVersion/eligibility/conflict-check';

  // Applications
  static const String applicationsMe = '$apiVersion/applications/me';
  static const String applications = '$apiVersion/applications';
  static String applicationStatus(String id) => '$apiVersion/applications/$id/status';
  static String applicationTimeline(String id) => '$apiVersion/applications/$id/timeline';
  static String applicationDeficiencies(String id) => '$apiVersion/applications/$id/deficiencies';
  static String applicationPaymentStatus(String id) => '$apiVersion/applications/$id/payment-status';
  static String applicationPayments(String id) => '$apiVersion/applications/$id/payments';
  static String applicationDocuments(String id) => '$apiVersion/applications/$id/documents';
  static String applicationVerifications(String id) => '$apiVersion/applications/$id/verifications';
  static String applicationTransition(String id) => '$apiVersion/applications/$id/transition';

  // Verifications
  static String verificationExecute(String id) => '$apiVersion/verifications/$id/execute';

  // Manual Review Queue
  static const String manualReviews = '$apiVersion/manual-reviews';
  static String manualReviewDecide(String id) => '$apiVersion/manual-reviews/$id/decide';

  // Analytics & Ministry Dashboard
  static const String analyticsDashboard = '$apiVersion/analytics/dashboard';
  static const String analyticsUnreached = '$apiVersion/analytics/unreached-beneficiaries';
  static const String analyticsUnreachedAll = '$apiVersion/analytics/unreached-beneficiaries/all';
  static const String analyticsOutreach = '$apiVersion/analytics/unreached-beneficiaries/outreach';

  // Documents
  static const String documents = '$apiVersion/documents';

  // Notifications
  static const String notificationsMe = '$apiVersion/notifications/me';
  static const String notifications = '$apiVersion/notifications';
  static String markNotificationRead(String id) => '$apiVersion/notifications/$id/read';

  // JAGO Assistant
  static String jagoMessages(String conversationId) => '$apiVersion/jago/conversations/$conversationId/messages';
}
