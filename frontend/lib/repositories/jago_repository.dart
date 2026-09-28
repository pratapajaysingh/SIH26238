import '../models/jago_message.dart';

/// JagoRepository defines the contract for JAGO AI Guide interaction.
/// Conforms to Playbook (Section 21) and documented endpoints:
/// - POST /api/v1/jago/conversations/{id}/messages
/// - GET /api/v1/jago/conversations/{id}
abstract class JagoRepository {
  /// Sends a user message to JAGO and returns the structured response.
  /// Endpoint: POST /api/v1/jago/conversations/{conversationId}/messages
  /// Request body: { "message": "..." }
  /// Response: { "answer": "...", "sources": [...], "action": null }
  Future<JagoResponse> sendMessage({
    required String conversationId,
    required String message,
  });

  /// Fetches conversation messages history.
  Future<List<JagoMessage>> getConversationMessages(String conversationId);

  /// Creates a new conversation session.
  /// Endpoint: POST /api/v1/jago/conversations
  Future<String> createConversation();
}
