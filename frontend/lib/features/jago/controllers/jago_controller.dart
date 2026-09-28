import 'package:flutter/foundation.dart';
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
  String _conversationId = 'conv-default';
  List<JagoMessage> _messages = [];

  static const List<String> suggestionChips = [
    'Tell me about Post Matric',
    'Am I eligible?',
    'What documents are required?',
  ];

  static const List<Map<String, String>> askAboutOptions = [
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

  /// Sends a message into the conversation
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

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
      );

      final asstMsg = JagoMessage.fromResponse(
        id: 'asst-${DateTime.now().millisecondsSinceEpoch}',
        response: response,
        timestamp: DateTime.now(),
      );
      _messages.add(asstMsg);
    } catch (e) {
      _errorMessage = 'Failed to get answer from JAGO. Please try again.';
      debugPrint('Error sending message to JAGO: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Clears error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
