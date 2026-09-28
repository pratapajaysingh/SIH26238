/// ApiResponse models the standard response envelope documented in
/// Team Development & Integration Playbook (Section 11).
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
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String? ?? '',
      requestId: json['request_id'] as String?,
    );
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
