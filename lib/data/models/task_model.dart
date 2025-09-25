import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  @override
  final TaskPriority priority;

  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.isCompleted,
    required this.priority,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Parse start_time and end_time which may be returned as String or DateTime
    dynamic startRaw = json['start_time'];
    dynamic endRaw = json['end_time'];

    DateTime parseDynamicDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is DateTime) return v;
      if (v is String) return DateTime.parse(v);
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      // fallback: try toString then parse
      return DateTime.parse(v.toString());
    }

    final startDt = parseDynamicDate(startRaw);
    final endDt = parseDynamicDate(endRaw);

    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      // Derive a date field from the start time (used by presentation layer to compare days)
      date: DateTime(startDt.year, startDt.month, startDt.day),
      startTime: startDt,
      endTime: endDt,
      isCompleted: json['is_completed'] as bool,
      priority: () {
        final p = json['priority'];
        if (p == null) return TaskPriority.normal;
        if (p is String) {
          switch (p.toLowerCase()) {
            case 'low':
              return TaskPriority.low;
            case 'high':
              return TaskPriority.high;
            default:
              return TaskPriority.normal;
          }
        }
        return TaskPriority.normal;
      }(),
    );
  }

  Map<String, dynamic> toJson() {
    // For updates, send the fields that exist in the DB (no separate `date` column)
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_completed': isCompleted,
      'priority': priority.name,
    };
  }

  // Método para convertir a JSON para inserción (sin id si es auto-generado)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'title': title,
      'description': description,
      // Store start_time and end_time (no `date` column in the DB schema)
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_completed': isCompleted,
      'priority': priority.name,
    };
  }

  // Método para convertir a TaskEntity
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      date: date,
      startTime: startTime,
      endTime: endTime,
      isCompleted: isCompleted,
      priority: priority,
    );
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      date: entity.date,
      startTime: entity.startTime,
      endTime: entity.endTime,
      isCompleted: entity.isCompleted,
      priority: entity.priority,
    );
  }

  @override
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    TaskPriority? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }
}
