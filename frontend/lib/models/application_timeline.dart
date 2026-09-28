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
    return ApplicationTimelineEvent(
      id: json['id'] as String,
      applicationId: json['application_id'] as String,
      stage: json['stage'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
      dateFormatted: json['date_formatted'] as String? ?? '-',
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
