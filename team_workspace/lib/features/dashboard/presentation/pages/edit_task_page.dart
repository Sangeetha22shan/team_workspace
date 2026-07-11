import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_workspace/injection/service_locator.dart';
import 'package:team_workspace/core/widgets/app_snackbar.dart';
import 'package:team_workspace/core/widgets/custom_text_form_field.dart';
import 'package:team_workspace/core/widgets/custom_dropdown_form_field.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/dashboard_usecase.dart';
import '../bloc/task_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({Key? key, required this.task}) : super(key: key);

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String _priority = 'Medium';
  String _status = 'Pending';
  String _assignedTo = 'Unassigned';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isSaving = false;

  late final DashboardUseCase _useCase;


  @override
  void initState() {
    super.initState();
    _useCase = getIt<DashboardUseCase>();

    final t = widget.task;
    _titleController = TextEditingController(text: t.title);
    _descriptionController = TextEditingController(text: t.description);
    _priority = t.priority;
    _status = t.status;
    _assignedTo = t.assignedTo;
    _dueDate = t.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      status: _status,
      dueDate: _dueDate,
      assignedTo: _assignedTo,
    );

    try {
      final result = await _useCase.updateTask(task: updatedTask);
      result.fold((failure) {
        AppSnackBar.show(
          context,
          'Failed to update: ${failure.message}',
          type: AppSnackBarType.error,
        );
      }, (task) {
        // dispatch update to BLoC so list refreshes
        context.read<TaskBloc>().add(UpdateTaskEvent(task: task));
        AppSnackBar.show(context, 'Task updated', type: AppSnackBarType.success);
        Navigator.of(context).pop(task);
      });
    } catch (e) {
      AppSnackBar.show(
        context,
        'Unexpected error: $e',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                controller: _titleController,
                labelText: 'Title',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Title is required';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextFormField(
                controller: _descriptionController,
                labelText: 'Description',

              ),
              const SizedBox(height: 12),
              CustomDropdownFormField<String>(
                initialValue: _priority,
                items: const ['Low', 'Medium', 'High'],
                itemLabel: (item) => item,
                onChanged: (v) {
                  if (v != null) setState(() => _priority = v);
                },
                labelText: 'Priority',
              ),
              const SizedBox(height: 12),
              CustomDropdownFormField<String>(
                initialValue: _status,
                items: const ['Pending', 'In Progress', 'Completed'],
                itemLabel: (item) => item,
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
                labelText: 'Status',
              ),
              const SizedBox(height: 12),
              CustomDropdownFormField<String>(
                initialValue: _assignedTo,
                items: TaskBloc.teamMembers,
                itemLabel: (item) => item,
                onChanged: (v) {
                  if (v != null) setState(() => _assignedTo = v);
                },
                labelText: 'Assign To',
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDueDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Due Date'),
                    controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd').format(_dueDate),
                    ),
                    validator: (v) {
                      if (_dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                        return 'Due date must be in the future';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  child: _isSaving ? const CircularProgressIndicator() : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


