/// ApiConstants defines locked endpoint paths conforming to the authoritative API contract.
class ApiConstants {
  ApiConstants._();

  // Base URL (configured via environment in production)
  static const String baseUrl = 'https://api.tribalsetu.gov.in';
  static const String apiVersion = '/api/v1';

  // Auth endpoints
  static const String authOtpSend = '$apiVersion/auth/otp/send';
  static const String authOtpVerify = '$apiVersion/auth/otp/verify';
  static const String authDigiLocker = '$apiVersion/auth/digilocker';
  static const String authApaar = '$apiVersion/auth/apaar';
  static const String authAadhaarOtpSend = '$apiVersion/auth/aadhaar/otp';
  static const String authAadhaarOtpVerify = '$apiVersion/auth/aadhaar/verify';
  static const String authMe = '$apiVersion/auth/me';

  // Documented Core endpoints
  static const String studentProfile = '$apiVersion/student/profile';
  static const String studentSummary = '$apiVersion/student/summary';
  static const String scholarships = '$apiVersion/scholarships';
  static String scholarshipDetails(String id) => '$apiVersion/scholarships/$id';
  static const String eligibilityCheck = '$apiVersion/eligibility/check';
  static const String applications = '$apiVersion/applications';
  static String applicationTimeline(String id) => '$apiVersion/applications/$id/timeline';
  static String applicationVerifications(String id) => '$apiVersion/applications/$id/verifications';
  static String applicationPayments(String id) => '$apiVersion/applications/$id/payments';
  static String applicationSubmit(String id) => '$apiVersion/applications/$id/submit';
  static String applicationDocuments(String id) => '$apiVersion/applications/$id/documents';
  static String applicationDocument(String id, String documentId) => '$apiVersion/applications/$id/documents/$documentId';
  static const String documents = '$apiVersion/documents';
  static const String documentsDigiLockerConsent = '$apiVersion/documents/digilocker/consent';
  static const String payments = '$apiVersion/payments';
  static const String notifications = '$apiVersion/notifications';
  static String markNotificationRead(String id) => '$apiVersion/notifications/$id/read';
  static const String jagoConversations = '$apiVersion/jago/conversations';
  static String jagoMessages(String conversationId) => '$apiVersion/jago/conversations/$conversationId/messages';
}
