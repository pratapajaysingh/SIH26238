import 'package:flutter/foundation.dart';

/// LanguageOption represents a supported system language in TribalSetu.
class LanguageOption {
  final String code;
  final String displayCode;
  final String name;
  final String nativeName;

  const LanguageOption({
    required this.code,
    required this.displayCode,
    required this.name,
    required this.nativeName,
  });
}

/// LanguageService manages the active language state synchronized across
/// GovernmentHeader, JagoScreen, and localized static UI strings.
class LanguageService extends ChangeNotifier {
  LanguageService._();
  static final LanguageService _instance = LanguageService._();
  static LanguageService get instance => _instance;

  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;
  String get displayCode => _currentLanguage.toUpperCase();

  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(
      code: 'en',
      displayCode: 'EN',
      name: 'English',
      nativeName: 'English',
    ),
    LanguageOption(
      code: 'hi',
      displayCode: 'HI',
      name: 'Hindi',
      nativeName: 'हिन्दी',
    ),
    LanguageOption(
      code: 'sat',
      displayCode: 'SAT',
      name: 'Santali',
      nativeName: 'ᱥᱟᱱᱛᱟᱲᱤ',
    ),
    LanguageOption(
      code: 'or',
      displayCode: 'OR',
      name: 'Odia',
      nativeName: 'ଓଡ଼ିଆ',
    ),
    LanguageOption(
      code: 'gon',
      displayCode: 'GON',
      name: 'Gondi',
      nativeName: 'गोण्डी',
    ),
  ];

  /// Sets the active language and notifies all listening UI components
  void setLanguage(String code) {
    final normalized = code.toLowerCase().trim();
    if (_currentLanguage != normalized) {
      _currentLanguage = normalized;
      notifyListeners();
    }
  }

  // Localized strings dictionary for key static strings across Dashboard & Applications
  static const Map<String, Map<String, String>> _localizedStrings = {
    'app_name': {
      'en': 'TribalSetu',
      'hi': 'ट्राइबलसेतु',
      'sat': 'ᱴᱨᱟᱭᱵᱟᱞᱥᱮᱛᱩ',
      'or': 'ଟ୍ରାଇବାଲସେତୁ',
      'gon': 'ट्राइबलसेतु',
    },
    'govt_of_india': {
      'en': 'Government of India',
      'hi': 'भारत सरकार',
      'sat': 'ᱵᱷᱟᱨᱚᱛ ᱥᱚᱨᱠᱟᱨ',
      'or': 'ଭାରତ ସରକାର',
      'gon': 'भारत सरकार',
    },
    'mota_title': {
      'en': 'Ministry of Tribal Affairs',
      'hi': 'जनजातीय कार्य मंत्रालय',
      'sat': 'ᱟᱹᱫᱤᱵᱟᱹᱥᱤ ᱠᱟᱹᱢᱤᱦᱚᱨᱟ ᱢᱚᱱᱛᱨᱟᱲᱚᱭ',
      'or': 'ଜନଜାତି ବ୍ୟାପାର ମନ୍ତ୍ରଣାଳୟ',
      'gon': 'जनजातीय कार्य मंत्रालय',
    },
    'dashboard_title': {
      'en': 'Student Dashboard',
      'hi': 'छात्र डैशबोर्ड',
      'sat': 'ᱯᱟᱹᱴᱷᱩᱣᱟᱹ ᱰᱮᱥᱵᱳᱨᱰ',
      'or': 'ଛାତ୍ର ଡ୍ୟାସବୋର୍ଡ',
      'gon': 'विद्यार्थी डैशबोर्ड',
    },
    'my_applications': {
      'en': 'My Applications',
      'hi': 'मेरे आवेदन',
      'sat': 'ᱤᱧᱟᱜ ᱟᱵᱮᱫᱚᱱ ᱠᱚ',
      'or': 'ମୋର ଆବେଦନଗୁଡ଼ିକ',
      'gon': 'नावा अर्जियांग',
    },
    'scholarships': {
      'en': 'Scholarships',
      'hi': 'छात्रवृत्तियां',
      'sat': 'ᱥᱠᱚᱞᱟᱨᱥᱤᱯ ᱠᱚ',
      'or': 'ଛାତ୍ରବୃତ୍ତିଗୁଡ଼ିକ',
      'gon': 'छात्रवृत्ति',
    },
    'check_eligibility': {
      'en': 'Check Eligibility',
      'hi': 'पात्रता जांचें',
      'sat': 'ᱯᱟᱛᱨᱚᱛᱟ ᱵᱤᱰᱟᱹᱣ ᱢᱮ',
      'or': 'ଯୋଗ୍ୟତା ଯାଞ୍ଚ କରନ୍ତୁ',
      'gon': 'पात्रता चोख कीम',
    },
    'jago_assistant': {
      'en': 'JAGO Assistant',
      'hi': 'जागो सहायक',
      'sat': 'JAGO ᱜᱚᱲᱚᱭᱤᱡ',
      'or': 'JAGO ସହାୟକ',
      'gon': 'JAGO साथी',
    },
    'dbt_payment_status': {
      'en': 'DBT Payment Status',
      'hi': 'डीबीटी भुगतान स्थिति',
      'sat': 'DBT ᱴᱟᱠᱟ ᱵᱷᱮᱡᱟ ᱚᱵᱚᱥᱛᱟ',
      'or': 'DBT ଦେୟ ସ୍ଥିତି',
      'gon': 'DBT पयका हाल-चाल',
    },
    'digilocker_wallet': {
      'en': 'DigiLocker Wallet',
      'hi': 'डिजिलॉकर वॉलेट',
      'sat': 'DigiLocker ᱣᱟᱞᱮᱴ',
      'or': 'ଡିଜିଲକର ୱାଲେଟ୍',
      'gon': 'डिजिलॉकर वॉलेट',
    },
  };

  /// Returns translated string for key, falling back to English
  String t(String key) {
    final entry = _localizedStrings[key];
    if (entry == null) return key;
    return entry[_currentLanguage] ?? entry['en'] ?? key;
  }
}
