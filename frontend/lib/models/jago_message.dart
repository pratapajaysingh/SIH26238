/// JagoResponse models the documented API response from:
/// POST /api/v1/jago/conversations/{id}/messages
/// Response format:
/// {
///   "answer": "Your Post-Matric application is currently under District Verification.",
///   "sources": ["application_status"],
///   "action": null
/// }
class JagoResponse {
  final String answer;
  final List<String> sources;
  final String? action;

  const JagoResponse({
    required this.answer,
    this.sources = const [],
    this.action,
  });

  factory JagoResponse.fromJson(Map<String, dynamic> json) {
    return JagoResponse(
      answer: json['answer'] as String? ?? '',
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      action: json['action'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'sources': sources,
      'action': action,
    };
  }
}

/// JagoMessage represents an item in the chat transcript.
class JagoMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final List<String> sources;
  final String? action;

  const JagoMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.sources = const [],
    this.action,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory JagoMessage.fromResponse({
    required String id,
    required JagoResponse response,
    DateTime? timestamp,
  }) {
    return JagoMessage(
      id: id,
      role: 'assistant',
      content: response.answer,
      timestamp: timestamp ?? DateTime.now(),
      sources: response.sources,
      action: response.action,
    );
  }

  factory JagoMessage.user({
    required String id,
    required String content,
    DateTime? timestamp,
  }) {
    return JagoMessage(
      id: id,
      role: 'user',
      content: content,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  factory JagoMessage.fromJson(Map<String, dynamic> json) {
    return JagoMessage(
      id: json['id'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      content: json['content'] as String? ?? (json['answer'] as String? ?? ''),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      action: json['action'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'sources': sources,
      'action': action,
    };
  }
}
