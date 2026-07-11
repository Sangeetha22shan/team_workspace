import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_workspace/core/widgets/app_snackbar.dart';
import '../bloc/task_bloc.dart';
import 'edit_task_page.dart';

import '../../domain/entities/task.dart';


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
    final newStatus = _currentTask.status == 'Completed' ? 'Pending' : 'Completed';

    final updatedTask = _currentTask.copyWith(status: newStatus);

    // Update UI immediately
    setState(() => _currentTask = updatedTask);

    // Dispatch event to persist change and update list UI via BLoC
    try {
      context.read<TaskBloc>().add(UpdateTaskEvent(task: updatedTask));

      if (mounted) {
        AppSnackBar.show(context, 'Task updated', type: AppSnackBarType.success);
      }
    } catch (e) {
      // If dispatching fails, revert UI and show error
      setState(() => _currentTask = _currentTask.copyWith(status: _currentTask.status));
      if (mounted) {
        AppSnackBar.show(
          context,
          'Error updating task: $e',
          type: AppSnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EditTaskPage(task: _currentTask)),
              );

              if (result is Task) {
                setState(() => _currentTask = result);
              }
            },
          ),
        ],
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
                  label: Text(
                    _currentTask.status,
                    style: TextStyle(
                      color: _contrastingTextColor(
                        _getStatusColor(_currentTask.status),
                        context,
                      ),
                    ),
                  ),
                  backgroundColor: _getStatusColor(_currentTask.status),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    _currentTask.priority,
                    style: TextStyle(
                      color: _contrastingTextColor(
                        _getPriorityColor(_currentTask.priority),
                        context,
                      ),
                    ),
                  ),
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
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentTask.description,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _toggleTaskStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentTask.status == 'Completed'
                      ? Colors.orange
                      : Colors.green,
                ),
                child: Text(
                  _currentTask.status == 'Completed'
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green.shade200;
      case 'In Progress':
        return Colors.orange.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red.shade200;
      case 'Medium':
        return Colors.orange.shade200;
      default:
        return Colors.green.shade200;
    }
  }

  Color _contrastingTextColor(Color background, BuildContext context) {
    // Use Flutter's brightness estimator to pick a readable text color
    final brightness = ThemeData.estimateBrightnessForColor(background);
    if (brightness == Brightness.dark) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }
}