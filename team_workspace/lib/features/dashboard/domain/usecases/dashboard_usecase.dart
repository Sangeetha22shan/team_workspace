import 'package:dartz/dartz.dart' hide Task;
import 'package:team_workspace/core/error/failures.dart';

import '../entities/task.dart';
import '../repositories/task_repository.dart';

class DashboardUseCase {
  final TaskRepository repository;

  DashboardUseCase(this.repository);

  Future<Either<Failure, List<Task>>> getTasks({
    required int limit,
    int? page,
    int? lastId,
  }) {
    return repository.getTasks(page: page, limit: limit, lastId: lastId);
  }


  Future<Either<Failure, List<Task>>> searchTasks({
    required String query,
    String? statusFilter,
    String? priorityFilter,
  }) {
    return repository.searchTasks(
      query: query,
      statusFilter: statusFilter,
      priorityFilter: priorityFilter,
    );
  }

  Future<Either<Failure, Task>> updateTask({
    required Task task,
  }) {
    return repository.updateTask(task);
  }

  Future<Either<Failure, Task>> createTask({
    required Task task,
  }) {
    return repository.createTask(task);
  }
}

