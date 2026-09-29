import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/jago_message.dart';
import 'jago_repository.dart';

/// ApiJagoRepository implements JagoRepository by communicating with the real JAGO backend
/// using the exact documented contract:
/// - POST /api/v1/jago/conversations/{id}/messages
class ApiJagoRepository implements JagoRepository {
  final ApiClient apiClient;
  final Map<String, List<JagoMessage>> _inMemoryHistory = {};

  ApiJagoRepository({required this.apiClient});

  @override
  Future<JagoResponse> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    final response = await apiClient.post<JagoResponse>(
      ApiConstants.jagoMessages(conversationId),
      body: {'message': message},
      fromJson: (json) => JagoResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      final res = response.data!;
      // Record interaction locally in conversation history
      _inMemoryHistory.putIfAbsent(conversationId, () => []);
      _inMemoryHistory[conversationId]!.add(
        JagoMessage.user(
          id: 'user-${DateTime.now().millisecondsSinceEpoch}',
          content: message,
        ),
      );
      _inMemoryHistory[conversationId]!.add(
        JagoMessage.fromResponse(
          id: 'asst-${DateTime.now().millisecondsSinceEpoch}',
          response: res,
        ),
      );
      return res;
    }

    throw ApiException(
      response.message.isNotEmpty ? response.message : 'Failed to send message to JAGO',
    );
  }

  @override
  Future<List<JagoMessage>> getConversationMessages(String conversationId) async {
    return _inMemoryHistory[conversationId] ?? [];
  }

  @override
  Future<String> createConversation() async {
    // Backend JAGO conversations are created implicitly upon first message
    return 'conv-${DateTime.now().millisecondsSinceEpoch}';
  }
}
