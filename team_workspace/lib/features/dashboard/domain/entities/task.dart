import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int id;
  final String title;
  final String description;
  final String priority; // Low, Medium, High
  final String status; // Pending, In Progress, Completed
  final DateTime dueDate;
  final String assignedTo;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.assignedTo,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? dueDate,
    String? assignedTo,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    priority,
    status,
    dueDate,
    assignedTo,
  ];
}