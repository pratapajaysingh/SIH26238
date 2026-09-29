class JagoResponse {
  final String answer;
  final List<String> sources;
  final String? action;
  final List<String> suggestions;
  final String? intent;
  final Map<String, dynamic>? data;

  const JagoResponse({
    required this.answer,
    this.sources = const [],
    this.action,
    this.suggestions = const [],
    this.intent,
    this.data,
  });

  factory JagoResponse.fromJson(Map<String, dynamic> json) {
    final rawAnswer = (json['message'] ?? json['answer'] ?? '').toString();
    final rawSources = json['sources'] != null
        ? (json['sources'] as List<dynamic>).map((e) => e.toString()).toList()
        : (json['source'] != null ? [json['source'].toString()] : const <String>[]);
    final rawSuggestions = (json['suggestions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    return JagoResponse(
      answer: rawAnswer,
      sources: rawSources,
      action: json['action'] as String?,
      suggestions: rawSuggestions,
      intent: json['intent'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'sources': sources,
      'action': action,
      'suggestions': suggestions,
      if (intent != null) 'intent': intent,
      if (data != null) 'data': data,
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
