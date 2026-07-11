

import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.priority,
    required super.status,
    required super.dueDate,
    required super.assignedTo,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Handle both "title" and "todo" fields from API
    final title = json['title'] as String? ?? json['todo'] as String? ?? 'Untitled';

    // Handle both "status" and "completed" fields from API
    final status = json['status'] as String? ??
        ((json['completed'] as bool? ?? false) ? 'Completed' : 'Pending');

    // Handle userId as assignedTo
    final assignedTo = json['assignedTo'] as String? ??
        (json['userId'] != null ? 'User ${json['userId']}' : 'Unassigned');

    return TaskModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: title,
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Medium',
      status: status,
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 7)),
      assignedTo: assignedTo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'assignedTo': assignedTo,
    };
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      status: task.status,
      dueDate: task.dueDate,
      assignedTo: task.assignedTo,
    );
  }
}