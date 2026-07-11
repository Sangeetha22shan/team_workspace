import 'package:dartz/dartz.dart' hide Task;
import 'package:team_workspace/core/error/exceptions.dart';
import 'package:team_workspace/core/error/failures.dart';
import 'package:team_workspace/core/network/network_info.dart';

import '../../domain/entities/task.dart';
import '../models/task_model.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasource/local_task_datasource.dart';
import '../datasource/remote_task_datasource.dart';


class TaskRepositoryImpl implements TaskRepository {
  final RemoteTaskDataSource remoteDataSource;
  final LocalTaskDataSource localDataSource;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Task>>> getTasks({
    int? page,
    required int limit,
    int? lastId,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          // Fetch all tasks from API (JSONPlaceholder doesn't support pagination the same way)
          final remoteTasks = await remoteDataSource.getTasks(
            page: page ?? 1,
            limit: limit,
          );
          // Cache all tasks in local storage (replace existing cache)
          await localDataSource.cacheAllTasks(remoteTasks);

          // Return paginated results from local DB so UI always reads from local source
          final paged = await localDataSource.getCachedTasks(page: page, limit: limit, lastId: lastId);
          return Right(paged);
        } on ServerException catch (e) {
          // If API fails even with internet, try to load from cache as fallback
          final cachedTasks = await localDataSource.getCachedTasks(page: page, limit: limit, lastId: lastId);
          if (cachedTasks.isNotEmpty) {
            return Right(cachedTasks);
          }
          return Left(
            ServerFailure(message: e.message, code: e.code),
          );
        }
      } else {
        // Load from local storage when offline
        final cachedTasks = await localDataSource.getCachedTasks(page: page, limit: limit, lastId: lastId);
        if (cachedTasks.isEmpty) {
          return Left(NetworkFailure(message: 'No internet connection and no cached tasks'));
        }
        return Right(cachedTasks);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Task>> getTaskById(int id) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteTask = await remoteDataSource.getTaskById(id);
        await localDataSource.cacheTask(remoteTask);
        return Right(remoteTask);
      } else {
        final cachedTask = await localDataSource.getCachedTask(id);
        if (cachedTask == null) {
          return Left(NetworkFailure(message: 'No internet connection'));
        }
        return Right(cachedTask);
      }
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, code: e.code),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      // Persist to local cache (DB)
      final taskModel = TaskModel.fromEntity(task);
      await localDataSource.cacheTask(taskModel);
      return Right(task);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to update task'));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final created = await localDataSource.createTask(taskModel);
      return Right(created);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to create task: $e'));
    }
  }

    @override
    Future<Either<Failure, List<Task>>> searchTasks({
      required String query,
      required String? statusFilter,
      required String? priorityFilter,
    }) async {
      try {
        // Get all tasks from local storage
        final cachedTasks = await localDataSource.getCachedTasks();

        var filtered = cachedTasks.where((task) {
          final matchesQuery =
              task.title.toLowerCase().contains(query.toLowerCase()) ||
                  task.description
                      .toLowerCase()
                      .contains(query.toLowerCase());

          final matchesStatus =
              statusFilter == null || task.status == statusFilter;
          final matchesPriority =
              priorityFilter == null || task.priority == priorityFilter;

          return matchesQuery && matchesStatus && matchesPriority;
        }).toList();


        return Right(filtered);
      } catch (e) {
        return Left(UnknownFailure(message: 'An unexpected error occurred'));
      }
    }
}