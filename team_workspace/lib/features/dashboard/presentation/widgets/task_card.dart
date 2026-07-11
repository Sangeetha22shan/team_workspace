import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with ID and status icon
              Row(
                children: [
                  Text(
                    '#${task.id}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: (theme.textTheme.bodySmall?.color ?? Colors.black54).withAlpha((0.8 * 255).round()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _getStatusColor(task.status),
                    child: Icon(
                      _getStatusIcon(task.status),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  // Priority and Status chips
                  Chip(
                    label: Text(
                      task.priority,
                      style: TextStyle(
                        fontSize: 10,
                        color: _contrastingTextColor(_getPriorityColor(task.priority), context),
                      ),
                    ),
                    backgroundColor: _getPriorityColor(task.priority),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status).withAlpha((0.12 * 255).round()),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: (theme.brightness == Brightness.dark && task.status.toLowerCase() == 'pending')
                            ? Colors.red
                            : _getStatusColor(task.status),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      task.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: (theme.brightness == Brightness.dark && task.status.toLowerCase() == 'pending')
                            ? Colors.white
                            : _contrastingTextColor(_getStatusColor(task.status), context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              // Description
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color ?? Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              // Due date and Assigned to row
              Row(
                children: [
                  // Due date
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: (theme.iconTheme.color ?? Colors.grey).withAlpha((0.6 * 255).round())),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Due: ${_formatDate(task.dueDate)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Assigned to
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 14, color: (theme.iconTheme.color ?? Colors.grey).withAlpha((0.6 * 255).round())),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'To: ${task.assignedTo}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Footer with arrow
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward_ios, size: 14, color: (theme.iconTheme.color ?? Colors.grey).withAlpha((0.6 * 255).round())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.grey;
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle;
      case 'In Progress':
        return Icons.pending_actions;
      default:
        return Icons.schedule;
    }
  }

  Color _contrastingTextColor(Color background, BuildContext context) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}