import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/core/network/api_response.dart';
import 'package:tribalsetu/models/jago_message.dart';
import 'package:tribalsetu/repositories/jago_repository.dart';
import 'package:tribalsetu/features/jago/controllers/jago_controller.dart';
import 'package:tribalsetu/features/jago/screens/jago_screen.dart';

class MockJagoRepoForTest implements JagoRepository {
  final Map<String, dynamic> rawJsonResponse;

  MockJagoRepoForTest(this.rawJsonResponse);

  @override
  Future<String> createConversation() async => 'conv-test-1';

  @override
  Future<List<JagoMessage>> getConversationMessages(String conversationId) async => [];

  @override
  Future<JagoResponse> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    // 1. Simulate ApiClient / ApiResponse
    final apiResponse = ApiResponse<JagoResponse>.fromJson(
      rawJsonResponse,
      (json) {
        if (json is Map<String, dynamic>) {
          return JagoResponse.fromJson(json);
        } else if (json is Map) {
          return JagoResponse.fromJson(Map<String, dynamic>.from(json));
        }
        return JagoResponse(answer: json.toString());
      },
    );

    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!;
    }
    throw Exception('Failed: ${apiResponse.message}');
  }
}

void main() {
  group('JAGO End-to-End UI Data Flow Verification', () {
    test('Query 1: My application status with nested data object', () async {
      const rawJsonString = '''{
        "conversation_id": "conv-test-1",
        "intent": "APPLICATION_STATUS",
        "message": "Your scholarship application (00000000-0000-0000-0000-000000000020) is currently in 'DRAFT' status.",
        "data": {
          "id": "00000000-0000-0000-0000-000000000020",
          "status": "DRAFT"
        },
        "source": "application_service.get_application_status",
        "suggestions": [
          "Why is my application pending?",
          "What is my payment status?"
        ],
        "language": "en"
      }''';

      final decoded = jsonDecode(rawJsonString);
      final repo = MockJagoRepoForTest(decoded as Map<String, dynamic>);
      final controller = JagoController(jagoRepository: repo);

      await controller.sendMessage('My application status');

      expect(controller.messages.length, 2);
      final asstMsg = controller.messages[1];
      expect(asstMsg.isAssistant, isTrue);
      expect(asstMsg.content, contains("in 'DRAFT' status"));
      expect(asstMsg.content.isNotEmpty, isTrue);
    });

    test('Query 2: Who created you and what can you do with data: null', () async {
      const rawJsonString = '''{
        "conversation_id": "conv-test-1",
        "intent": "UNKNOWN",
        "message": "I am JAGO, your AI Assistant for TribalSetu. I can help track your application, check eligibility, verify documents, and explain benefits.",
        "data": null,
        "source": "jago_rule_engine",
        "suggestions": [
          "Check my application status"
        ],
        "language": "en"
      }''';

      final decoded = jsonDecode(rawJsonString);
      final repo = MockJagoRepoForTest(decoded as Map<String, dynamic>);
      final controller = JagoController(jagoRepository: repo);

      await controller.sendMessage('Who created you and what can you do?');

      expect(controller.messages.length, 2);
      final asstMsg = controller.messages[1];
      expect(asstMsg.isAssistant, isTrue);
      expect(asstMsg.content, contains("I am JAGO"));
      expect(asstMsg.content.isNotEmpty, isTrue);
    });
    testWidgets('Widget Test: JagoScreen renders assistant text bubble for "My application status"', (tester) async {
      const rawJsonString = '''{
        "conversation_id": "conv-test-1",
        "intent": "APPLICATION_STATUS",
        "message": "Your scholarship application (00000000-0000-0000-0000-000000000020) is currently in 'DRAFT' status.",
        "data": {
          "id": "00000000-0000-0000-0000-000000000020",
          "status": "DRAFT"
        },
        "source": "application_service.get_application_status",
        "suggestions": ["Why is my application pending?"],
        "language": "en"
      }''';

      final decoded = jsonDecode(rawJsonString);
      final repo = MockJagoRepoForTest(decoded as Map<String, dynamic>);
      final controller = JagoController(jagoRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: JagoScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      await controller.sendMessage('My application status');
      await tester.pumpAndSettle();

      // Verify that the assistant text is rendered directly on screen
      expect(find.textContaining("is currently in 'DRAFT' status"), findsOneWidget);
    });

    testWidgets('Widget Test: JagoScreen renders assistant text bubble for "Who created you and what can you do?"', (tester) async {
      const rawJsonString = '''{
        "conversation_id": "conv-test-1",
        "intent": "UNKNOWN",
        "message": "I am JAGO, your AI Assistant for TribalSetu.",
        "data": null,
        "source": "jago_rule_engine",
        "suggestions": ["Check my application status"],
        "language": "en"
      }''';

      final decoded = jsonDecode(rawJsonString);
      final repo = MockJagoRepoForTest(decoded as Map<String, dynamic>);
      final controller = JagoController(jagoRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: JagoScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      await controller.sendMessage('Who created you and what can you do?');
      await tester.pumpAndSettle();

      // Verify that the assistant text is rendered directly on screen
      expect(find.textContaining('I am JAGO, your AI Assistant'), findsOneWidget);
    });

    testWidgets('Widget Test: JagoScreen renders assistant text bubble for "What is my payment status?"', (tester) async {
      const rawJsonString = '''{
        "conversation_id": "conv-test-C",
        "intent": "PAYMENT_STATUS",
        "message": "Your DBT payment status is 'NOT_INITIATED': Payment has not been initiated.",
        "data": {"status": "NOT_INITIATED"},
        "source": "payment_service.get_payment_status",
        "suggestions": ["Check my application status"],
        "language": "en"
      }''';

      final decoded = jsonDecode(rawJsonString);
      final repo = MockJagoRepoForTest(decoded as Map<String, dynamic>);
      final controller = JagoController(jagoRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: JagoScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      await controller.sendMessage('What is my payment status?');
      await tester.pumpAndSettle();

      expect(find.textContaining("Your DBT payment status is 'NOT_INITIATED'"), findsOneWidget);
    });

    testWidgets('Widget Test: JagoScreen renders assistant text bubble for "Why is my application pending?"', (tester) async {
      const rawJsonString = '''{
        "conversation_id": "conv-test-D",
        "intent": "UNKNOWN",
        "message": "I'm sorry, I could not determine what action you'd like to take. JAGO can assist with checking your scholarship application status...",
        "data": null,
        "source": "jago_rule_engine",
        "suggestions": ["Check my application status"],
        "language": "en"
      }''';

      final decoded = jsonDecode(rawJsonString);
      final repo = MockJagoRepoForTest(decoded as Map<String, dynamic>);
      final controller = JagoController(jagoRepository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: JagoScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      await controller.sendMessage('Why is my application pending?');
      await tester.pumpAndSettle();

      expect(find.textContaining('I could not determine what action'), findsOneWidget);
    });
  });
}
