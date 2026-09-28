import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/jago_message.dart';
import 'jago_repository.dart';

/// ApiJagoRepository implements JagoRepository by communicating with the real JAGO backend
/// using the exact documented contract:
/// - POST /api/v1/jago/conversations/{id}/messages
/// - GET /api/v1/jago/conversations/{id}
/// - POST /api/v1/jago/conversations
class ApiJagoRepository implements JagoRepository {
  final ApiClient apiClient;

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
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<List<JagoMessage>> getConversationMessages(String conversationId) async {
    final response = await apiClient.get(
      '${ApiConstants.jagoConversations}/$conversationId',
    );
    if (response.success && response.data != null) {
      final data = response.data;
      if (data is List<dynamic>) {
        return data.map((e) => JagoMessage.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map<String, dynamic> && data['messages'] is List<dynamic>) {
        return (data['messages'] as List<dynamic>)
            .map((e) => JagoMessage.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  @override
  Future<String> createConversation() async {
    final response = await apiClient.post(
      ApiConstants.jagoConversations,
    );
    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      return data['id'] as String? ?? 'conv-default';
    }
    return 'conv-default';
  }
}
