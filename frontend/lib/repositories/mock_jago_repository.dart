import '../models/jago_message.dart';
import 'jago_repository.dart';

/// MockJagoRepository provides deterministic mock conversation data strictly conforming
/// to the documented JAGO API contract and reproducing the reference conversation.
class MockJagoRepository implements JagoRepository {
  final Duration latency;

  MockJagoRepository({this.latency = const Duration(milliseconds: 300)});

  static final List<JagoMessage> _initialConversation = [
    JagoMessage(
      id: 'msg-user-01',
      role: 'user',
      content: 'What are the scholarships available for ST students?',
      timestamp: DateTime(2024, 10, 15, 9, 41),
    ),
    JagoMessage(
      id: 'msg-asst-01',
      role: 'assistant',
      content:
          'Here are the major scholarships available for ST (Scheduled Tribe) students under TribalSetu:\n\n'
          '1. Pre Matric Scholarship for ST Students\n'
          '2. Post Matric Scholarship for ST Students\n'
          '3. Top Class Education Scheme for ST Students\n'
          '4. National Fellowship for ST Students\n'
          '5. National Overseas Scholarship for ST Students\n\n'
          'Each scheme has different eligibility criteria, benefits and application timelines. Would you like to know details about any specific scheme?',
      timestamp: DateTime(2024, 10, 15, 9, 41),
      sources: ['scheme_catalogue', 'mota_guidelines'],
    ),
  ];

  final Map<String, List<JagoMessage>> _conversations = {};

  @override
  Future<List<JagoMessage>> getConversationMessages(String conversationId) async {
    await Future.delayed(latency);
    if (!_conversations.containsKey(conversationId)) {
      _conversations[conversationId] = List.from(_initialConversation);
    }
    return List.from(_conversations[conversationId]!);
  }

  @override
  Future<String> createConversation() async {
    await Future.delayed(latency);
    final id = 'conv-${DateTime.now().millisecondsSinceEpoch}';
    _conversations[id] = List.from(_initialConversation);
    return id;
  }

  @override
  Future<JagoResponse> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    await Future.delayed(latency);

    final queryLower = message.trim().toLowerCase();
    String answer;
    List<String> sources = ['mota_guidelines'];

    if (queryLower.contains('post matric') || queryLower.contains('post-matric')) {
      answer =
          'Post Matric Scholarship for ST Students:\n\n'
          '• Coverage: Higher education from Class 11 to Post-Doctoral studies.\n'
          '• Income Limit: Family annual income up to ₹2,50,000.\n'
          '• Benefits: Full tuition fees + maintenance allowance up to ₹48,000/year.\n'
          '• Mode of Disbursement: Direct Benefit Transfer (DBT) to student bank account.';
      sources = ['post_matric_guidelines', 'benefit_matrix'];
    } else if (queryLower.contains('eligible') || queryLower.contains('eligibility')) {
      answer =
          'Eligibility Criteria for ST Scholarships:\n\n'
          '1. Must belong to a recognized Scheduled Tribe (ST) community.\n'
          '2. Annual family income within scheme ceilings (≤ ₹2.5 Lakh for Post-Matric).\n'
          '3. Valid enrollment in an approved institution/course.\n'
          '4. Valid DigiLocker or verified Caste Certificate.\n'
          '5. Active Aadhaar-seeded bank account for DBT.';
      sources = ['eligibility_service', 'caste_rules'];
    } else if (queryLower.contains('document') || queryLower.contains('documents')) {
      answer =
          'Required Documents for Application:\n\n'
          '1. Valid ST Caste Certificate (from DigiLocker or issuing authority)\n'
          '2. Competent Authority Income Certificate\n'
          '3. Previous Year Academic Marksheet\n'
          '4. Institute Admission / Fee Receipt\n'
          '5. Student Bank Account Passbook (Aadhaar linked)\n'
          '6. Passport size photo & signature';
      sources = ['document_service', 'verification_checklist'];
    } else if (queryLower.contains('application') || queryLower.contains('process') || queryLower.contains('apply')) {
      answer =
          'Application Process Steps:\n\n'
          '1. Login to TribalSetu using Mobile OTP or DigiLocker.\n'
          '2. Complete or verify your student profile.\n'
          '3. Browse schemes in "Find Scholarships" and select eligible scheme.\n'
          '4. Review pre-filled academic & demographic data.\n'
          '5. Submit. Track live status through Institute, District, and State verification stages.';
      sources = ['application_workflow', 'process_guide'];
    } else if (queryLower.contains('deadline') || queryLower.contains('last date')) {
      answer =
          'Important Application Deadlines (2024-25):\n\n'
          '• Top Class Education Scheme: 15 Oct 2024\n'
          '• Post Matric Scholarship for ST: 31 Oct 2024\n'
          '• Pre Matric Scholarship for ST: 15 Nov 2024\n'
          '• Scholarship for ST in Medical Courses: 20 Nov 2024\n'
          '• National Fellowship for ST: 30 Nov 2024';
      sources = ['scheme_calendar', 'mota_notifications'];
    } else if (queryLower.contains('scholarship') || queryLower.contains('scheme')) {
      answer =
          'Here are the major scholarships available for ST (Scheduled Tribe) students under TribalSetu:\n\n'
          '1. Pre Matric Scholarship for ST Students\n'
          '2. Post Matric Scholarship for ST Students\n'
          '3. Top Class Education Scheme for ST Students\n'
          '4. National Fellowship for ST Students\n'
          '5. National Overseas Scholarship for ST Students\n\n'
          'Each scheme has different eligibility criteria, benefits and application timelines. Would you like to know details about any specific scheme?';
      sources = ['scheme_catalogue', 'mota_guidelines'];
    } else {
      answer =
          'I am JAGO, your AI guide for Ministry of Tribal Affairs (MoTA) scholarships. '
          'You can ask me about scheme details, eligibility requirements, necessary documents, '
          'application tracking, or deadlines. How may I assist your scholarship journey today?';
      sources = ['jago_knowledge_base'];
    }

    final response = JagoResponse(
      answer: answer,
      sources: sources,
      action: null,
    );

    // Persist in mock conversation list
    if (!_conversations.containsKey(conversationId)) {
      _conversations[conversationId] = List.from(_initialConversation);
    }
    _conversations[conversationId]!.add(
      JagoMessage.user(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        content: message,
      ),
    );
    _conversations[conversationId]!.add(
      JagoMessage.fromResponse(
        id: 'asst-${DateTime.now().millisecondsSinceEpoch}',
        response: response,
      ),
    );

    return response;
  }
}
