/// ApiResponse models the standard response envelope for TribalSetu.
/// Supports both explicit envelopes ({success, data, message}) and direct FastAPI payloads.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final String? requestId;

  const ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.requestId,
  });

  factory ApiResponse.fromJson(
    dynamic json,
    T Function(dynamic json)? fromJsonT,
  ) {
    if (json is Map<String, dynamic>) {
      final bool hasExplicitSuccess = json.containsKey('success');
      final bool success = hasExplicitSuccess ? (json['success'] as bool? ?? false) : true;

      dynamic rawData;
      if (json.containsKey('data')) {
        rawData = json['data'];
      } else if (!hasExplicitSuccess) {
        rawData = json;
      } else {
        rawData = null;
      }

      final T? parsedData = rawData != null && fromJsonT != null
          ? fromJsonT(rawData)
          : (rawData is T ? rawData : null);

      return ApiResponse<T>(
        success: success,
        data: parsedData,
        message: json['message'] as String? ?? json['detail'] as String? ?? '',
        requestId: json['request_id'] as String?,
      );
    } else {
      // Direct JSON List or primitive value
      final T? parsedData = json != null && fromJsonT != null
          ? fromJsonT(json)
          : (json is T ? json : null);

      return ApiResponse<T>(
        success: true,
        data: parsedData,
        message: '',
      );
    }
  }

  Map<String, dynamic> toJson([dynamic Function(T value)? toJsonT]) {
    return {
      'success': success,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
      'message': message,
      'request_id': requestId,
    };
  }
}
