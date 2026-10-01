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
    String? language,
  }) async {
    await Future.delayed(latency);

    final queryLower = message.trim().toLowerCase();
    String answer;
    List<String> sources = ['mota_guidelines'];

    if (language == 'sat' || queryLower.contains('ᱡᱚᱦᱟᱨ') || queryLower.contains('ᱥᱟᱱᱛᱟᱲᱤ')) {
      if (queryLower.contains('payment') || queryLower.contains('dbt') || queryLower.contains('ᱴᱟᱠᱟ')) {
        answer =
            'DBT ᱴᱟᱠᱟ ᱵᱷᱮᱡᱟ ᱚᱵᱚᱥᱛᱟ:\n\n'
            '• ᱴᱟᱠᱟ ᱵᱷᱮᱡᱟ ᱦᱚᱨᱟ: PFMS ᱦᱚᱛᱮᱛᱮ Direct Benefit Transfer (DBT)\n'
            '• ᱵᱮᱸᱠ ᱮᱠᱟᱣᱩᱱᱴ: ᱟᱫᱷᱟᱨ ᱡᱚᱲᱟᱣ ᱮᱠᱟᱣᱩᱱᱴ ᱵᱤᱰᱟᱹᱣ ᱦᱩᱭ ᱟᱠᱟᱱᱟ\n'
            '• ᱱᱤᱛᱚᱜᱟᱜ ᱚᱵᱚᱥᱛᱟ: ᱯᱨᱚᱥᱮᱥ ᱟᱠᱟᱱᱟ / ᱵᱷᱮᱡᱟᱜ ᱠᱟᱱᱟ (In Transit)';
        sources = ['payment_service', 'pfms_adapter'];
      } else if (queryLower.contains('eligible') || queryLower.contains('ᱡᱚᱜᱽ')) {
        answer =
            'ST ᱥᱠᱚᱞᱟᱨᱥᱤᱯ ᱞᱟᱹᱜᱤᱫ ᱯᱟᱛᱨᱚᱛᱟ ᱢᱟᱱᱫᱚᱸᱰ:\n\n'
            '᱑. ᱢᱟᱹᱱ ᱟᱱ ST (Scheduled Tribe) ᱜᱩᱴ ᱨᱤᱱᱤᱡ ᱦᱩᱭᱩᱜ ᱞᱟᱹᱠᱛᱤᱜ-ᱟ।\n'
            '᱒. ᱜᱷᱟᱨᱚᱸᱡᱽ ᱨᱮᱱᱟᱜ ᱥᱮᱨᱢᱟᱠᱤᱭᱟᱹ ᱟᱨᱡᱟᱣ ≤ ₹᱒.᱕ ᱞᱟᱠᱷ।\n'
            '᱓. ᱢᱟᱹᱱ ᱟᱱ ᱤᱱᱥᱴᱤᱴᱭᱩᱴ ᱨᱮ ᱵᱷᱩᱨᱛᱤ ᱛᱟᱦᱮᱸᱱ ᱞᱟᱹᱠᱛᱤᱜ-ᱟ।\n'
            '᱔. ᱟᱫᱷᱟᱨ ᱥᱟᱶ ᱡᱚᱲᱟᱣ ᱵᱮᱸᱠ ᱮᱠᱟᱣᱩᱱᱴ ᱛᱟᱦᱮᱸᱱ ᱞᱟᱹᱠᱛᱤᱜ-ᱟ।';
        sources = ['eligibility_service', 'mota_guidelines'];
      } else if (queryLower.contains('document') || queryLower.contains('ᱠᱟᱜᱚᱡᱽ')) {
        answer =
            'ᱥᱠᱚᱞᱟᱨᱥᱤᱯ ᱞᱟᱹᱜᱤᱫ ᱞᱟᱹᱠᱛᱤᱭᱟᱱ ᱠᱟᱜᱚᱡᱽ ᱠᱚ:\n\n'
            '᱑. ST ᱡᱟᱹᱛᱤ ᱥᱟᱠᱟᱢ (Caste Certificate)\n'
            '᱒. ᱟᱨᱡᱟᱣ ᱥᱟᱠᱟᱢ (Income Certificate)\n'
            '᱓. ᱢᱟᱲᱟᱝ ᱥᱮᱨᱢᱟ ᱨᱮᱱᱟᱜ ᱢᱟᱨᱠᱥᱤᱴ\n'
            '᱔. ᱟᱫᱷᱟᱨ ᱠᱟᱨᱰ\n'
            '᱕. ᱵᱮᱸᱠ ᱯᱟᱥᱵᱩᱠ\n'
            '᱖. ᱵᱷᱩᱨᱛᱤ ᱨᱟᱹᱥᱤᱫ';
        sources = ['document_service'];
      } else {
        answer =
            'ᱡᱚᱦᱟᱨ! ᱤᱧ ᱫᱚ JAGO, ᱟᱹᱫᱤᱵᱟᱹᱥᱤ ᱠᱟᱹᱢᱤᱦᱚᱨᱟ ᱢᱚᱱᱛᱨᱟᱲᱚᱭ (MoTA) ᱨᱮᱱ AI ᱥᱠᱚᱞᱟᱨᱥᱤᱯ ᱜᱚᱲᱚᱭᱤᱡ। '
            'ᱟᱢᱟᱜ ᱟᱵᱮᱫᱚᱱ, ᱯᱟᱛᱨᱚᱛᱟ, ᱠᱟᱜᱚᱡᱽ, ᱟᱨ DBT ᱴᱟᱠᱟ ᱵᱟᱵᱚᱛ ᱠᱩᱠᱞᱤ ᱠᱩᱞᱤ ᱫᱟᱲᱮᱭᱟᱜ-ᱟᱢ।';
        sources = ['jago_knowledge_base'];
      }
    } else if (language == 'or' || queryLower.contains('ନମସ୍କାର') || queryLower.contains('ଓଡ଼ିଆ')) {
      if (queryLower.contains('payment') || queryLower.contains('dbt') || queryLower.contains('ଦେୟ')) {
        answer =
            'DBT ଦେୟ ସ୍ଥିତି:\n\n'
            '• ବିତରଣ ମୋଡ୍: PFMS ମାଧ୍ୟମରେ Direct Benefit Transfer (DBT)\n'
            '• ବ୍ୟାଙ୍କ ଖାତା: ଆଧାର-ଲିଙ୍କ୍ ହୋଇଥିବା ଖାତା ଯାଞ୍ଚ ହୋଇଛି\n'
            '• ବର୍ତ୍ତମାନ ସ୍ଥିତି: ପ୍ରକ୍ରିୟାକରଣ ଚାଲିଛି / ପ୍ରଦାନ କରାଯାଉଛି (In Transit)';
        sources = ['payment_service', 'pfms_adapter'];
      } else if (queryLower.contains('eligible') || queryLower.contains('ଯୋଗ୍ୟ')) {
        answer =
            'ST ଛାତ୍ରବୃତ୍ତି ପାଇଁ ଯୋଗ୍ୟତା ମାନଦଣ୍ଡ:\n\n'
            '୧. ସ୍ୱୀକୃତିପ୍ରାପ୍ତ ଅନୁସୂଚିତ ଜନଜାତି (ST) ସମ୍ପ୍ରଦାୟର ହୋଇଥିବା ଆବଶ୍ୟକ।\n'
            '୨. ପରିବାରର ବାର୍ଷିକ ଆୟ ସୀମା ≤ ₹୨.୫ ଲକ୍ଷ।\n'
            '୩. ସ୍ୱୀକୃତିପ୍ରାପ୍ତ ଅନୁଷ୍ଠାନରେ ପଢୁଥିବା ଆବଶ୍ୟକ।\n'
            '୪. ସକ୍ରିୟ ଆଧାର-ସିଡେଡ୍ ବ୍ୟାଙ୍କ ଖାତା ରହିବା ଆବଶ୍ୟକ।';
        sources = ['eligibility_service', 'mota_guidelines'];
      } else if (queryLower.contains('document') || queryLower.contains('ଦଲିଲ')) {
        answer =
            'ଆବେଦନ ପାଇଁ ଆବଶ୍ୟକ ଦଲିଲଗୁଡ଼ିକ:\n\n'
            '୧. ବୈଧ ST ଜାତି ପ୍ରମାଣପତ୍ର\n'
            '୨. ସକ୍ଷମ କର୍ତ୍ତୃପକ୍ଷଙ୍କ ଆୟ ପ୍ରମାଣପତ୍ର\n'
            '୩. ପୂର୍ବ ବର୍ଷର ଶିକ୍ଷାଗତ ମାର୍କସିଟ୍\n'
            '୪. ଆଧାର କାର୍ଡ\n'
            '୫. ବ୍ୟାଙ୍କ ପାସବୁକ୍\n'
            '୬. ଅନୁଷ୍ଠାନ ନାମଲେଖା ରସିଦ';
        sources = ['document_service'];
      } else {
        answer =
            'ଜୋହାର / ନମସ୍କାର! ମୁଁ JAGO, ଜନଜାତି ବ୍ୟାପାର ମନ୍ତ୍ରଣାଳୟ (MoTA) ର ଆପଣଙ୍କର AI ଛାତ୍ରବୃତ୍ତି ସହାୟକ। '
            'ଆପଣଙ୍କର ଆବେଦନ, ଯୋଗ୍ୟତା, ଦଲିଲ ଏବଂ DBT ଦେୟ ସମ୍ପର୍କରେ କିଛି ବି ପଚାରିପାରିବେ।';
        sources = ['jago_knowledge_base'];
      }
    } else if (language == 'hi' || queryLower.contains('नमस्ते') || queryLower.contains('छात्रवृत्ति')) {
      if (queryLower.contains('payment') || queryLower.contains('dbt') || queryLower.contains('भुगतान') || queryLower.contains('पैसा')) {
        answer =
            'DBT भुगतान स्थिति:\n\n'
            '• संवितरण मोड: PFMS के माध्यम से प्रत्यक्ष लाभ अंतरण (DBT)\n'
            '• बैंक खाता: आधार-लिंक्ड बैंक खाता सत्यापित\n'
            '• वर्तमान स्थिति: संसाधित / लाभार्थी को प्रेषित (In Transit)';
        sources = ['payment_service', 'pfms_adapter'];
      } else if (queryLower.contains('eligible') || queryLower.contains('पात्र')) {
        answer =
            'एसटी छात्रवृत्ति के लिए पात्रता मानदंड:\n\n'
            '1. मान्यता प्राप्त अनुसूचित जनजाति (ST) समुदाय से संबंधित होना चाहिए।\n'
            '2. वार्षिक पारिवारिक आय ₹2.5 लाख से कम या बराबर होनी चाहिए।\n'
            '3. मान्यता प्राप्त संस्थान में अध्ययनरत होना चाहिए।\n'
            '4. आधार से जुड़ा बैंक खाता अनिवार्य है।';
        sources = ['eligibility_service', 'mota_guidelines'];
      } else if (queryLower.contains('document') || queryLower.contains('दस्तावेज़')) {
        answer =
            'आवेदन के लिए आवश्यक दस्तावेज़:\n\n'
            '1. वैध एसटी जाति प्रमाण पत्र (डिजीलॉकर से)\n'
            '2. सक्षम प्राधिकारी आय प्रमाण पत्र\n'
            '3. पिछले वर्ष की अंकतालिका\n'
            '4. आधार कार्ड\n'
            '5. बैंक पासबुक\n'
            '6. संस्थान शुल्क रसीद';
        sources = ['document_service'];
      } else {
        answer =
            'नमस्ते! मैं JAGO हूँ, जनजातीय कार्य मंत्रालय (MoTA) के लिए आपका AI छात्रवृत्ति सहायक। '
            'आप मुझसे योजनाओं, पात्रता, दस्तावेज़ों, आवेदन ट्रैकिंग या डीबीटी भुगतान के बारे में पूछ सकते हैं।';
        sources = ['jago_knowledge_base'];
      }
    } else if (queryLower.contains('payment') || queryLower.contains('dbt') || queryLower.contains('paisa')) {
      answer =
          'DBT Payment Status:\n\n'
          '• Disbursement Mode: Direct Benefit Transfer (DBT) via PFMS\n'
          '• Bank Account: Aadhaar-seeded account verified\n'
          '• Current Status: Processed / In Transit to Beneficiary\n'
          '• Note: Official DBT updates are routed via PFMS gateway.';
      sources = ['payment_service', 'pfms_adapter'];
    } else if (queryLower.contains('deficienc') || queryLower.contains('missing') || queryLower.contains('pending')) {
      answer =
          'Application Deficiency & Missing Documents Check:\n\n'
          '• Total Deficiencies Found: 0\n'
          '• Status: All required documents (ST Certificate, Income Certificate, Marksheet) are verified.\n'
          '• If your application is pending at Institute or District level, please allow 3-5 working days for verification.';
      sources = ['application_service', 'verification_checklist'];
    } else if (queryLower.contains('post matric') || queryLower.contains('post-matric')) {
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
