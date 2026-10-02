/// AppStrings stores the authoritative textual strings used across TribalSetu.
class AppStrings {
  AppStrings._();

  // Branding & Ministry
  static const String appName = 'TribalSetu';
  static const String tagline = 'One Platform. Every Opportunity.';
  static const String description = 'Unifying scholarships, empowering\ntribal students, building a brighter tomorrow.';
  static const String govtOfIndia = 'Government\nof India';
  static const String motaTitle = 'Ministry of Tribal Affairs';
  static const String bottomMotto = 'Education  •  Opportunity  •  Empowerment';

  // Language & Roles
  static const String defaultLanguage = 'EN';
  static const String roleStudent = 'Student';
  static const String roleAdmin = 'Admin';
  static const String roleInstitute = 'Institute';

  // Input Fields & Actions
  static const String emailPlaceholder = 'Enter your email address';
  static const String otpPlaceholder = '------';
  static const String sendCodeButton = 'Send code';
  static const String continueButton = 'Continue';
  static const String verifyButton = 'Verify & Continue';
  static const String resendCodeButton = 'Resend code';
  static const String changeEmailButton = 'Change email';
  static const String orDivider = 'OR';

  // Validation & Feedback Messages
  static const String emailRequired = 'Please enter your email address';
  static const String emailInvalid = 'Please enter a valid email address';
  static const String otpRequired = 'Please enter the 6-digit code';
  static const String otpInvalid = 'Invalid or expired code.';
  static const String networkError = 'Unable to connect to server. Please check your internet connection.';
  static const String serverError = 'Could not send the code right now. Please try again.';
  static const String rateLimitError = 'Too many requests. Please wait before trying again.';
}
