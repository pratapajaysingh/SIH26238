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

  // Auth Methods
  static const String methodMobile = 'Mobile Number';
  static const String methodAadhaar = 'Aadhaar';

  // Input Fields & Actions
  static const String countryCodeIndia = '+91';
  static const String mobilePlaceholder = 'Enter your mobile number';
  static const String aadhaarPlaceholder = 'Enter your 12-digit Aadhaar number';
  static const String continueButton = 'Continue';
  static const String orDivider = 'OR';

  // Action Cards
  static const String digilockerTitle = 'Continue with DigiLocker';
  static const String digilockerSubtitle = 'Access using your DigiLocker account';
  static const String apaarTitle = 'Continue with APAAR';
  static const String apaarSubtitle = 'Using your APAAR ID';

  // Validation Messages
  static const String mobileRequired = 'Please enter your mobile number';
  static const String mobileInvalid = 'Please enter a valid 10-digit mobile number';
  static const String aadhaarRequired = 'Please enter your Aadhaar number';
  static const String aadhaarInvalid = 'Please enter a valid 12-digit Aadhaar number';
  static const String otpRequired = 'Please enter the 6-digit OTP';
  static const String otpInvalid = 'Invalid OTP. Please check and try again.';
}
