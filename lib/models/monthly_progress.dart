class MonthlyProgress {
  final String id;
  final String projectId;
  final DateTime month;
  final double completionPercent;

  MonthlyProgress({
    required this.id,
    required this.projectId,
    required this.month,
    required this.completionPercent,
  });

  factory MonthlyProgress.fromJson(Map<String, dynamic> json) {
    return MonthlyProgress(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      month: DateTime.parse(json['month'] as String),
      completionPercent: (json['completion_percent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'month': month.toIso8601String().split('T')[0],
      'completion_percent': completionPercent,
    };
  }
}
