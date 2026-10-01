import 'package:flutter/foundation.dart';
import '../../../core/services/language_service.dart';
import '../../../models/jago_message.dart';
import '../../../repositories/jago_repository.dart';

/// JagoController manages the JAGO AI chat state, message flow,
/// suggestion chips, shortcut prompts, and repository integration.
/// Strictly follows: UI -> Controller -> Repository -> ApiClient.
class JagoController extends ChangeNotifier {
  final JagoRepository jagoRepository;
  final String? initialConversationId;

  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  String _currentLanguage = LanguageService.instance.currentLanguage;
  String _conversationId = 'conv-default';
  List<JagoMessage> _messages = [];

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'हिन्दी'},
    {'code': 'sat', 'name': 'ᱥᱟᱱᱛᱟᱲᱤ'},
    {'code': 'or', 'name': 'ଓଡ଼ିଆ'},
    {'code': 'gon', 'name': 'गोण्डी'},
    {'code': 'hinglish', 'name': 'Hinglish'},
  ];

  static const List<String> suggestionChipsEn = [
    'My application status',
    'Why is my application pending?',
    'What documents are missing?',
    'Check my payment status',
    'Am I eligible for NFST?',
    'What scholarship schemes are available?',
  ];

  static const List<String> suggestionChipsHi = [
    'मेरे आवेदन की स्थिति जांचें',
    'मेरा आवेदन लंबित क्यों है?',
    'कौन से दस्तावेज़ गायब हैं?',
    'मेरी भुगतान स्थिति क्या है?',
    'क्या मैं पात्र हूँ?',
    'कौन सी छात्रवृत्ति योजनाएं उपलब्ध हैं?',
  ];

  static const List<String> suggestionChipsHinglish = [
    'Mera application status kya hai?',
    'Mera application pending kyu hai?',
    'Kaun se documents missing hain?',
    'Payment status check karo',
    'Kya main NFST ke liye eligible hu?',
    'Kaun si scholarship schemes available hain?',
  ];

  static const List<String> suggestionChipsSat = [
    'ᱤᱧᱟᱜ ᱟᱵᱮᱫᱚᱱ ᱚᱵᱚᱥᱛᱟ',
    'ᱪᱮᱫᱟᱜ ᱟᱵᱮᱫᱚᱱ ᱵᱟᱹᱠᱤ ᱢᱮᱱᱟᱜ-ᱟ?',
    'ᱪᱮᱫ ᱠᱟᱜᱚᱡᱽ ᱠᱚᱢ ᱢᱮᱱᱟᱜ-ᱟ?',
    'DBT ᱴᱟᱠᱟ ᱚᱵᱚᱥᱛᱟ',
    'ᱪᱮᱫ ᱤᱧ ᱡᱚᱜᱽ ᱜᱮᱭᱟ?',
    'ᱥᱠᱚᱞᱟᱨᱥᱤᱯ ᱡᱚᱡᱚᱱᱟ ᱠᱚ',
  ];

  static const List<String> suggestionChipsOr = [
    'ମୋ ଆବେଦନ ସ୍ଥିତି ଯାଞ୍ଚ କରନ୍ତୁ',
    'ମୋ ଆବେଦନ କାହିଁକି ବିଚାରାଧୀନ?',
    'କେଉଁ ଦଲିଲଗୁଡ଼ିକ ବାକି ଅଛି?',
    'ମୋର DBT ଦେୟ ସ୍ଥିତି',
    'ମୁଁ କଣ ଯୋଗ୍ୟ ଅଟେ?',
    'ଉପଲବ୍ଧ ଛାତ୍ରବୃତ୍ତି ଯୋଜନା',
  ];

  static const List<String> suggestionChipsGon = [
    'नावा अर्जी रो हाल-चाल',
    'नावा अर्जी बारे ते कबर',
    'बतले कागजात पाहिजेल?',
    'नावा DBT पयका रो हाल-चाल',
    'पात्रता नतीजा',
    'छात्रवृत्ति योजना',
  ];

  static const List<String> suggestionChips = suggestionChipsEn;

  static const List<Map<String, String>> askAboutOptionsEn = [
    {
      'title': 'Scholarship\nSchemes',
      'prompt': 'What are the scholarships available for ST students?',
      'icon': 'school',
    },
    {
      'title': 'Eligibility\nCriteria',
      'prompt': 'What is the eligibility criteria for ST scholarships?',
      'icon': 'criteria',
    },
    {
      'title': 'Required\nDocuments',
      'prompt': 'What documents are required for applying to ST scholarships?',
      'icon': 'documents',
    },
    {
      'title': 'Application\nProcess',
      'prompt': 'How do I apply for scholarships on TribalSetu?',
      'icon': 'process',
    },
    {
      'title': 'Important\nDeadlines',
      'prompt': 'What are the important deadlines for scholarships?',
      'icon': 'deadlines',
    },
    {
      'title': 'General\nQueries',
      'prompt': 'Tell me how JAGO can help me with ST scholarship services.',
      'icon': 'queries',
    },
  ];

  static const List<Map<String, String>> askAboutOptionsHi = [
    {
      'title': 'छात्रवृत्ति\nयोजनाएं',
      'prompt': 'एसटी छात्रों के लिए कौन सी छात्रवृत्तियां उपलब्ध हैं?',
      'icon': 'school',
    },
    {
      'title': 'पात्रता\nमानदंड',
      'prompt': 'छात्रवृत्ति के लिए पात्रता मानदंड क्या हैं?',
      'icon': 'criteria',
    },
    {
      'title': 'आवश्यक\nदस्तावेज़',
      'prompt': 'छात्रवृत्ति आवेदन के लिए कौन से दस्तावेज़ आवश्यक हैं?',
      'icon': 'documents',
    },
    {
      'title': 'आवेदन\nप्रक्रिया',
      'prompt': 'ट्राइबलसेतु पर छात्रवृत्ति के लिए कैसे आवेदन करें?',
      'icon': 'process',
    },
    {
      'title': 'महत्वपूर्ण\nतिथियां',
      'prompt': 'छात्रवृत्ति की महत्वपूर्ण समय सीमा क्या है?',
      'icon': 'deadlines',
    },
    {
      'title': 'सामान्य\nपूछताछ',
      'prompt': 'जागो (JAGO) मेरी क्या सहायता कर सकता है?',
      'icon': 'queries',
    },
  ];

  static const List<Map<String, String>> askAboutOptionsHinglish = [
    {
      'title': 'Scholarship\nSchemes',
      'prompt': 'ST students ke liye kaun kaun si scholarships available hain?',
      'icon': 'school',
    },
    {
      'title': 'Eligibility\nCriteria',
      'prompt': 'ST scholarships ke liye eligibility criteria kya hai?',
      'icon': 'criteria',
    },
    {
      'title': 'Required\nDocuments',
      'prompt': 'Scholarship apply karne ke liye kaun se documents chahiye?',
      'icon': 'documents',
    },
    {
      'title': 'Application\nProcess',
      'prompt': 'TribalSetu par scholarship kaise apply karein?',
      'icon': 'process',
    },
    {
      'title': 'Important\nDeadlines',
      'prompt': 'Scholarships ki important deadlines kya hain?',
      'icon': 'deadlines',
    },
    {
      'title': 'General\nQueries',
      'prompt': 'JAGO ST scholarship me meri kya help kar sakta hai?',
      'icon': 'queries',
    },
  ];

  static const List<Map<String, String>> askAboutOptionsSat = [
    {
      'title': 'ᱥᱠᱚᱞᱟᱨᱥᱤᱯ\nᱡᱚᱡᱚᱱᱟ',
      'prompt': 'ST ᱯᱟᱹᱴᱷᱩᱣᱟᱹ ᱠᱚ ᱞᱟᱹᱜᱤᱫ ᱪᱮᱫ ᱥᱠᱚᱞᱟᱨᱥᱤᱯ ᱢᱮᱱᱟᱜ-ᱟ?',
      'icon': 'school',
    },
    {
      'title': 'ᱯᱟᱛᱨᱚᱛᱟ\nᱢᱟᱱᱫᱚᱸᱰ',
      'prompt': 'ᱥᱠᱚᱞᱟᱨᱥᱤᱯ ᱞᱟᱹᱜᱤᱫ ᱯᱟᱛᱨᱚᱛᱟ ᱢᱟᱱᱫᱚᱸᱰ ᱪᱮᱫ ᱠᱟᱱᱟ?',
      'icon': 'criteria',
    },
    {
      'title': 'ᱞᱟᱹᱠᱛᱤᱭᱟᱱ\nᱠᱟᱜᱚᱡᱽ',
      'prompt': 'ᱥᱠᱚᱞᱟᱨᱥᱤᱯ ᱞᱟᱹᱜᱤᱫ ᱪᱮᱫ ᱠᱟᱜᱚᱡᱽ ᱞᱟᱹᱠᱛᱤᱜ-ᱟ?',
      'icon': 'documents',
    },
    {
      'title': 'ᱟᱵᱮᱫᱚᱱ\nᱦᱚᱨᱟ',
      'prompt': 'TribalSetu ᱨᱮ ᱥᱠᱚᱞᱟᱨᱥᱤᱯ ᱞᱟᱹᱜᱤᱫ ᱪᱮᱞᱠᱟᱛᱮ ᱟᱵᱮᱫᱚᱱ ᱦᱩᱭᱩᱜ-ᱟ?',
      'icon': 'process',
    },
    {
      'title': 'ᱢᱩᱬᱩᱛ\nᱛᱟᱹᱨᱤᱠᱷ',
      'prompt': 'ᱥᱠᱚᱞᱟᱨᱥᱤᱯ ᱨᱮᱱᱟᱜ ᱢᱩᱬᱩᱛ ᱛᱟᱹᱨᱤᱠᱷ ᱪᱮᱫ ᱠᱟᱱᱟ?',
      'icon': 'deadlines',
    },
    {
      'title': 'ᱥᱟᱫᱷᱟᱨᱚᱱ\nᱠᱩᱠᱞᱤ',
      'prompt': 'JAGO ᱤᱧᱟᱜ ᱪᱮᱫ ᱜᱚᱲᱚ ᱮᱢ ᱫᱟᱲᱮᱭᱟᱜ-ᱟ?',
      'icon': 'queries',
    },
  ];

  static const List<Map<String, String>> askAboutOptionsOr = [
    {
      'title': 'ଛାତ୍ରବୃତ୍ତି\nଯୋଜନା',
      'prompt': 'ST ଛାତ୍ରଛାତ୍ରୀଙ୍କ ପାଇଁ କେଉଁ ଛାତ୍ରବୃତ୍ତି ଉପଲବ୍ଧ?',
      'icon': 'school',
    },
    {
      'title': 'ଯୋଗ୍ୟତା\nମାନଦଣ୍ଡ',
      'prompt': 'ଛାତ୍ରବୃତ୍ତି ପାଇଁ ଯୋଗ୍ୟତା ମାନଦଣ୍ଡ କଣ?',
      'icon': 'criteria',
    },
    {
      'title': 'ଆବଶ୍ୟକ\nଦଲିଲ',
      'prompt': 'ଛାତ୍ରବୃତ୍ତି ଆବେଦନ ପାଇଁ କେଉଁ ଦଲିଲ ଆବଶ୍ୟକ?',
      'icon': 'documents',
    },
    {
      'title': 'ଆବେଦନ\nପ୍ରକ୍ରିୟା',
      'prompt': 'TribalSetu ରେ ଛାତ୍ରବୃତ୍ତି ପାଇଁ କିପରି ଆବେଦନ କରିବେ?',
      'icon': 'process',
    },
    {
      'title': 'ଗୁରୁତ୍ୱପୂର୍ଣ୍ଣ\nତାରିଖ',
      'prompt': 'ଛାତ୍ରବୃତ୍ତିର ଗୁରୁତ୍ୱପୂର୍ଣ୍ଣ ଶେଷ ତାରିଖ କଣ?',
      'icon': 'deadlines',
    },
    {
      'title': 'ସାଧାରଣ\nପ୍ରଶ୍ନ',
      'prompt': 'JAGO ମୋତେ କିପରି ସାହାଯ୍ୟ କରିପାରିବ?',
      'icon': 'queries',
    },
  ];

  static const List<Map<String, String>> askAboutOptions = askAboutOptionsEn;

  String get currentLanguage => _currentLanguage;

  List<String> get localizedSuggestionChips {
    switch (_currentLanguage) {
      case 'hi':
        return suggestionChipsHi;
      case 'sat':
        return suggestionChipsSat;
      case 'or':
        return suggestionChipsOr;
      case 'gon':
        return suggestionChipsGon;
      case 'hinglish':
        return suggestionChipsHinglish;
      default:
        return suggestionChipsEn;
    }
  }

  List<Map<String, String>> get localizedAskAboutOptions {
    switch (_currentLanguage) {
      case 'hi':
        return askAboutOptionsHi;
      case 'sat':
        return askAboutOptionsSat;
      case 'or':
        return askAboutOptionsOr;
      case 'hinglish':
        return askAboutOptionsHinglish;
      default:
        return askAboutOptionsEn;
    }
  }

  void setLanguage(String lang) {
    if (_currentLanguage != lang) {
      _currentLanguage = lang;
      LanguageService.instance.setLanguage(lang);
      notifyListeners();
    }
  }

  JagoController({
    required this.jagoRepository,
    this.initialConversationId,
  }) {
    if (initialConversationId != null) {
      _conversationId = initialConversationId!;
    }
  }

  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  String get conversationId => _conversationId;
  List<JagoMessage> get messages => List.unmodifiable(_messages);

  /// Loads the conversation history
  Future<void> loadConversation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _messages = await jagoRepository.getConversationMessages(_conversationId);
    } catch (e) {
      _errorMessage = 'Unable to load conversation. Please check your connection and retry.';
      debugPrint('Error loading JAGO conversation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _lastSentMessage;

  String? get lastSentMessage => _lastSentMessage;

  /// Sends a message into the conversation
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    _lastSentMessage = trimmed;

    // 1. Optimistically append user message
    final userMsg = JagoMessage.user(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      content: trimmed,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    // 2. Transmit through repository
    try {
      final response = await jagoRepository.sendMessage(
        conversationId: _conversationId,
        message: trimmed,
        language: _currentLanguage == 'hinglish' ? 'hi' : _currentLanguage,
      );

      final asstMsg = JagoMessage.fromResponse(
        id: 'asst-${DateTime.now().millisecondsSinceEpoch}',
        response: response,
        timestamp: DateTime.now(),
      );

      debugPrint('[JAGO_CONTROLLER] Appending assistant message: "${asstMsg.content}" (id: ${asstMsg.id})');
      _messages.add(asstMsg);
    } catch (e) {
      _errorMessage = 'Failed to get answer from JAGO. Please try again.';
      debugPrint('[JAGO_CONTROLLER] Error sending message to JAGO: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Retries the last attempted message
  Future<void> retryLastMessage() async {
    if (_lastSentMessage != null && !_isSending) {
      final retryText = _lastSentMessage!;
      _errorMessage = null;
      notifyListeners();
      await sendMessage(retryText);
    }
  }

  /// Clears error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
