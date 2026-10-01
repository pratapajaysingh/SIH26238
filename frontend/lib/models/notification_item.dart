/// NotificationItem models an alert or notification received by the student.
/// Follows documented endpoint GET /api/v1/notifications and database contract:
/// [id, user_id, type, title, message, application_id, is_read, created_at]
class NotificationItem {
  final String id;
  final String? userId;
  final String type;
  final String title;
  final String message;
  final String? applicationId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    this.userId,
    this.type = 'APPLICATION_UPDATE',
    required this.title,
    required this.message,
    this.applicationId,
    required this.isRead,
    required this.createdAt,
  });

  NotificationItem copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    String? applicationId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      applicationId: applicationId ?? this.applicationId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      type: (json['type'] ?? json['notification_type'] ?? json['category']) as String? ?? 'APPLICATION_UPDATE',
      title: json['title'] as String,
      message: json['message'] as String,
      applicationId: json['application_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      if (applicationId != null) 'application_id': applicationId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
