import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/features/dashboard/widgets/custom_bottom_nav_bar.dart';
import 'package:tribalsetu/features/dashboard/widgets/dashboard_header.dart';
import 'package:tribalsetu/features/jago/controllers/jago_controller.dart';
import 'package:tribalsetu/features/jago/screens/jago_screen.dart';
import 'package:tribalsetu/features/jago/widgets/jago_ask_about_section.dart';
import 'package:tribalsetu/features/jago/widgets/jago_benefits_card.dart';
import 'package:tribalsetu/features/jago/widgets/jago_chat_bubble.dart';
import 'package:tribalsetu/features/jago/widgets/jago_intro_header.dart';
import 'package:tribalsetu/features/jago/widgets/jago_message_composer.dart';
import 'package:tribalsetu/features/jago/widgets/jago_suggestion_chips.dart';
import 'package:tribalsetu/models/jago_message.dart';
import 'package:tribalsetu/repositories/jago_repository.dart';
import 'package:tribalsetu/repositories/mock_jago_repository.dart';

class FailingJagoRepository implements JagoRepository {
  bool shouldFail = true;

  @override
  Future<String> createConversation() async => 'conv-fail';

  @override
  Future<List<JagoMessage>> getConversationMessages(String conversationId) async => [];

  @override
  Future<JagoResponse> sendMessage({
    required String conversationId,
    required String message,
    String? language,
  }) async {
    if (shouldFail) {
      throw Exception('Network error');
    }
    return const JagoResponse(answer: 'Retried success answer');
  }
}

void main() {
  group('JagoController Unit Tests', () {
    late JagoController controller;
    late MockJagoRepository repository;

    setUp(() {
      repository = MockJagoRepository(latency: Duration.zero);
      controller = JagoController(jagoRepository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Loads initial conversation history correctly', () async {
      expect(controller.isLoading, isTrue);

      await controller.loadConversation();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.messages.length, equals(2));
      expect(controller.messages.first.isUser, isTrue);
      expect(controller.messages.first.content, contains('scholarships available for ST students'));
      expect(controller.messages.last.isAssistant, isTrue);
      expect(controller.messages.last.content, contains('Pre Matric Scholarship for ST Students'));
      expect(controller.messages.last.sources, contains('scheme_catalogue'));
    });

    test('Sending message appends user message and assistant answer', () async {
      await controller.loadConversation();

      await controller.sendMessage('Tell me about Post Matric');

      expect(controller.messages.length, equals(4));
      final userMsg = controller.messages[2];
      final asstMsg = controller.messages[3];

      expect(userMsg.isUser, isTrue);
      expect(userMsg.content, equals('Tell me about Post Matric'));

      expect(asstMsg.isAssistant, isTrue);
      expect(asstMsg.content, contains('Post Matric Scholarship for ST Students'));
      expect(asstMsg.sources, contains('post_matric_guidelines'));
    });

    test('Sending empty or whitespace message does nothing', () async {
      await controller.loadConversation();

      await controller.sendMessage('   ');

      expect(controller.messages.length, equals(2));
    });

    test('Eligibility query returns eligibility guidelines', () async {
      await controller.loadConversation();

      await controller.sendMessage('Am I eligible?');

      expect(controller.messages.length, equals(4));
      expect(controller.messages.last.content, contains('Eligibility Criteria'));
      expect(controller.messages.last.sources, contains('eligibility_service'));
    });

    test('Documents query returns required documents checklist', () async {
      await controller.loadConversation();

      await controller.sendMessage('What documents are required?');

      expect(controller.messages.length, equals(4));
      expect(controller.messages.last.content, contains('Required Documents'));
      expect(controller.messages.last.sources, contains('document_service'));
    });
  });

  group('JagoScreen Widget & Fidelity Tests', () {
    late JagoController controller;

    setUp(() {
      controller = JagoController(
        jagoRepository: MockJagoRepository(latency: Duration.zero),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createTestWidget({Size physicalSize = const Size(390, 844)}) {
      return MaterialApp(
        routes: {
          '/dashboard': (_) => const Scaffold(body: Text('Dashboard Mock')),
          '/scholarships': (_) => const Scaffold(body: Text('Scholarships Mock')),
        },
        home: MediaQuery(
          data: MediaQueryData(
            size: physicalSize,
            padding: const EdgeInsets.only(top: 44, bottom: 34),
          ),
          child: JagoScreen(
            controller: controller,
            studentInitials: 'AS',
            unreadNotificationsCount: 1,
          ),
        ),
      );
    }

    testWidgets('Renders all required visual components faithfully', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Dashboard Header
      expect(find.byType(DashboardHeader), findsOneWidget);

      // 2. JAGO Intro Header
      expect(find.byType(JagoIntroHeader), findsOneWidget);
      expect(find.text('Your AI Guide for Scholarships'), findsOneWidget);
      expect(find.textContaining('Ask anything about schemes'), findsOneWidget);

      // 3. Benefits Card Strip (3 Items)
      expect(find.byType(JagoBenefitsCard), findsOneWidget);
      expect(find.textContaining('Get instant'), findsOneWidget);
      expect(find.textContaining('Step-by-step'), findsOneWidget);
      expect(find.textContaining('Simpler'), findsOneWidget);

      // 4. Date separator
      expect(find.text('Today'), findsOneWidget);

      // 5. Chat Bubbles (Initial user question & assistant answer)
      expect(find.byType(JagoChatBubble), findsNWidgets(2));
      expect(find.text('What are the scholarships available for ST students?'), findsOneWidget);
      expect(find.textContaining('Here are the major scholarships available for ST'), findsOneWidget);

      // 6. Suggestion Chips
      expect(find.byType(JagoSuggestionChips), findsOneWidget);
      expect(find.text('My application status'), findsOneWidget);
      expect(find.text('Why is my application pending?'), findsOneWidget);

      // 7. You can also ask about section
      expect(find.byType(JagoAskAboutSection), findsOneWidget);
      expect(find.text('You can also ask about'), findsOneWidget);
      expect(find.textContaining('Scholarship'), findsWidgets);
      expect(find.textContaining('Eligibility'), findsWidgets);
      expect(find.textContaining('Required'), findsWidgets);

      // 8. Message Composer
      expect(find.byType(JagoMessageComposer), findsOneWidget);
      expect(find.text('Type your message...'), findsOneWidget);

      // 9. Fixed Bottom Navigation Bar
      expect(find.byType(CustomBottomNavBar), findsOneWidget);
    });

    testWidgets('Tapping suggestion chip sends message and appends answer', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(JagoChatBubble), findsNWidgets(2));

      // Tap 'My application status' chip
      await tester.tap(find.text('My application status'));
      await tester.pumpAndSettle();

      // Now 4 messages should be rendered
      expect(find.byType(JagoChatBubble), findsNWidgets(4));
      expect(find.text('My application status'), findsWidgets);
      expect(find.textContaining('Application'), findsWidgets);
    });

    testWidgets('Typing message in composer and tapping send button sends message', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'Important Deadlines');
      await tester.pumpAndSettle();

      // Tap send button
      await tester.tap(find.byIcon(Icons.near_me_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(JagoChatBubble), findsNWidgets(4));
      expect(find.textContaining('Important Application Deadlines'), findsOneWidget);
    });

    testWidgets('Tapping "You can also ask about" card sends prompt', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap Eligibility Criteria card
      final criteriaCard = find.descendant(
        of: find.byType(JagoAskAboutSection),
        matching: find.text('Eligibility\nCriteria'),
      );
      await tester.tap(criteriaCard);
      await tester.pumpAndSettle();

      expect(find.byType(JagoChatBubble), findsNWidgets(4));
      expect(find.textContaining('Eligibility Criteria for ST Scholarships'), findsOneWidget);
    });

    testWidgets('Displays error banner on failure and retries on tap', (tester) async {
      final failingRepo = FailingJagoRepository();
      final failController = JagoController(jagoRepository: failingRepo);

      await tester.pumpWidget(MaterialApp(home: JagoScreen(controller: failController)));
      await tester.pumpAndSettle();

      await failController.sendMessage('Test error message');
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to get answer from JAGO'), findsOneWidget);
      expect(find.byKey(const Key('jago_retry_button')), findsOneWidget);

      // Now switch repository to succeed and retry
      failingRepo.shouldFail = false;
      await tester.tap(find.byKey(const Key('jago_retry_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Retried success answer'), findsOneWidget);
    });
  });

  group('JagoScreen Responsive & Overflow Tests', () {
    Widget buildResponsiveTest({required Size size}) {
      final controller = JagoController(
        jagoRepository: MockJagoRepository(latency: Duration.zero),
      );
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            padding: const EdgeInsets.only(top: 44, bottom: 34),
          ),
          child: JagoScreen(
            controller: controller,
            studentInitials: 'AS',
            unreadNotificationsCount: 1,
          ),
        ),
      );
    }

    testWidgets('Zero overflow on Small Phone (360 x 640)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildResponsiveTest(size: const Size(360, 640)));
      await tester.pumpAndSettle();

      expect(find.byType(JagoScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Standard Phone (390 x 844)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildResponsiveTest(size: const Size(390, 844)));
      await tester.pumpAndSettle();

      expect(find.byType(JagoScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Tablet (768 x 1024)', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildResponsiveTest(size: const Size(768, 1024)));
      await tester.pumpAndSettle();

      expect(find.byType(JagoScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
