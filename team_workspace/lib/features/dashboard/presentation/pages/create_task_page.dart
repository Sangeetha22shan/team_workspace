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

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({Key? key}) : super(key: key);

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Medium';
  String _assignedTo = 'Unassigned';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isSaving = false;

  late final DashboardUseCase _useCase;


  @override
  void initState() {
    super.initState();
    _useCase = getIt<DashboardUseCase>();
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

    final newTask = Task(
      id: 0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      status: 'Pending',
      dueDate: _dueDate,
      assignedTo: _assignedTo,
    );

    try {
      final result = await _useCase.createTask(task: newTask);
      result.fold((failure) {
        AppSnackBar.show(
          context,
          'Failed to create: ${failure.message}',
          type: AppSnackBarType.error,
        );
        }, (task) {

        context.read<TaskBloc>().add(AddTaskToStateEvent(task: task));
        AppSnackBar.show(context, 'Task created', type: AppSnackBarType.success);
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
        title: const Text('Create Task'),
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
                  child: _isSaving ? const CircularProgressIndicator() : const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


