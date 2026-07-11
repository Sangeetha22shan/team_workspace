import 'package:dartz/dartz.dart' hide Task;
import 'package:team_workspace/core/error/failures.dart';

import '../entities/task.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasks({
    int? page,
    required int limit,
    int? lastId,
  });

  Future<Either<Failure, Task>> getTaskById(int id);


  Future<Either<Failure, List<Task>>> searchTasks({
    required String query,
    required String? statusFilter,
    required String? priorityFilter,
  });
}