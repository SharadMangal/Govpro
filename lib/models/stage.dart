class Stage {
  final String id;
  final String projectId;
  final String stageName;
  final int sequenceOrder;
  final double completionPercent;
  final DateTime startDate;
  final DateTime? endDate;

  Stage({
    required this.id,
    required this.projectId,
    required this.stageName,
    required this.sequenceOrder,
    required this.completionPercent,
    required this.startDate,
    this.endDate,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      stageName: json['stage_name'] as String,
      sequenceOrder: json['sequence_order'] as int,
      completionPercent: (json['completion_percent'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'stage_name': stageName,
      'sequence_order': sequenceOrder,
      'completion_percent': completionPercent,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
    };
  }
}
