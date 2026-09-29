/// ApplicationTimelineEvent models an individual stage in an application's progress lifecycle.
/// Follows documented endpoint GET /api/v1/applications/{id}/timeline.
class ApplicationTimelineEvent {
  final String id;
  final String applicationId;
  final String stage;
  final String title;
  final String? description;
  final String status; // COMPLETED, IN_PROGRESS, PENDING
  final DateTime? date;
  final String dateFormatted;
  final int stageIndex;

  const ApplicationTimelineEvent({
    required this.id,
    required this.applicationId,
    required this.stage,
    required this.title,
    this.description,
    required this.status,
    this.date,
    required this.dateFormatted,
    required this.stageIndex,
  });

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isInProgress => status.toUpperCase() == 'IN_PROGRESS';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isDeficiency => status.toUpperCase() == 'DEFICIENCY' || status.toUpperCase() == 'WARNING';
  bool get isRejected => status.toUpperCase() == 'REJECTED' || status.toUpperCase() == 'FAILED';

  factory ApplicationTimelineEvent.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? 'PENDING').toString();
    final rawDate = json['created_at'] ?? json['timestamp'] ?? json['date'];
    final parsedDate = rawDate != null ? DateTime.tryParse(rawDate.toString()) : null;
    final dateStr = json['date_formatted'] as String? ??
        (parsedDate != null ? '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}' : '-');

    return ApplicationTimelineEvent(
      id: (json['id'] ?? '').toString(),
      applicationId: (json['application_id'] ?? '').toString(),
      stage: (json['stage'] ?? json['status'] ?? 'DRAFT').toString(),
      title: (json['title'] ?? json['message'] ?? json['status'] ?? 'Status Update').toString(),
      description: json['description'] as String? ?? json['message'] as String?,
      status: rawStatus,
      date: parsedDate,
      dateFormatted: dateStr,
      stageIndex: json['stage_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      'stage': stage,
      'title': title,
      'description': description,
      'status': status,
      'date': date?.toIso8601String(),
      'date_formatted': dateFormatted,
      'stage_index': stageIndex,
    };
  }
}
