import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import 'package:team_workspace/core/constants/app_constants.dart';
import 'package:team_workspace/core/database/database_helper.dart';

import '../../domain/entities/task.dart';
import '../../data/models/task_model.dart';


class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Task _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  void _toggleTaskStatus() async {
    final newStatus = _currentTask.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;

    final updatedTask = _currentTask.copyWith(status: newStatus);

    // Update in SQLite database
    try {
      final dbHelper = GetIt.instance<DatabaseHelper>();
      final taskModel = TaskModel.fromEntity(updatedTask);
      final taskMap = taskModel.toJson();

      await dbHelper.updateTask(taskMap);

      setState(() => _currentTask = updatedTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              _currentTask.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Status and Priority
            Row(
              children: [
                Chip(
                  label: Text(_currentTask.status),
                  backgroundColor: _getStatusColor(_currentTask.status),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(_currentTask.priority),
                  backgroundColor: _getPriorityColor(_currentTask.priority),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Due Date
            _buildInfoSection(
              'Due Date',
              DateFormat('EEEE, MMM dd, yyyy – hh:mm a')
                  .format(_currentTask.dueDate),
            ),
            const SizedBox(height: 16),

            // Assigned To
            _buildInfoSection('Assigned To', _currentTask.assignedTo),
            const SizedBox(height: 16),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentTask.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _toggleTaskStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentTask.status == TaskStatus.completed
                      ? Colors.orange
                      : Colors.green,
                ),
                child: Text(
                  _currentTask.status == TaskStatus.completed
                      ? 'Reopen Task'
                      : 'Mark as Completed',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case TaskStatus.completed:
        return Colors.green.shade200;
      case TaskStatus.inProgress:
        return Colors.orange.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red.shade200;
      case TaskPriority.medium:
        return Colors.orange.shade200;
      default:
        return Colors.green.shade200;
    }
  }
}