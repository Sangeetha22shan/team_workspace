import 'package:team_workspace/core/database/database_helper.dart';
import 'package:team_workspace/core/error/exceptions.dart';

import '../models/task_model.dart';

abstract class LocalTaskDataSource {
  Future<void> cacheAllTasks(List<TaskModel> tasks);

  /// If [lastId] is provided, returns tasks where id > lastId (id-based pagination) limited by [limit].
  /// Otherwise, if [page] and [limit] are provided, returns paginated results using offset.
  /// If none provided, returns all cached tasks.
  Future<List<TaskModel>> getCachedTasks({int? page, int? limit, int? lastId});

  Future<void> clearCache();

  Future<void> cacheTask(TaskModel task);

  Future<TaskModel?> getCachedTask(int id);
}

class LocalTaskDataSourceImpl implements LocalTaskDataSource {
  final DatabaseHelper databaseHelper;

  LocalTaskDataSourceImpl(this.databaseHelper);

  @override
  Future<void> cacheAllTasks(List<TaskModel> tasks) async {
    try {
      // Clear existing tasks first
      await databaseHelper.deleteAllTasks();

      // Insert all new tasks
      final taskMaps = tasks.map((task) => task.toJson()).toList();
      await databaseHelper.insertAllTasks(taskMaps);
    } catch (e) {
      throw CacheException('Failed to cache tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getCachedTasks({int? page, int? limit, int? lastId}) async {
    try {
      List<Map<String, dynamic>> taskMaps;

      if (lastId != null && limit != null) {
        taskMaps = await databaseHelper.getTasksAfterId(lastId: lastId, limit: limit);
      } else if (page != null && limit != null) {
        final offset = (page - 1) * limit;
        taskMaps = await databaseHelper.getTasks(limit: limit, offset: offset);
      } else {
        taskMaps = await databaseHelper.getAllTasks();
      }

      return taskMaps.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException('Failed to get cached tasks: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await databaseHelper.deleteAllTasks();
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    try {
      final taskMap = task.toJson();
      await databaseHelper.updateTask(taskMap);
    } catch (e) {
      throw CacheException('Failed to cache task: $e');
    }
  }

  @override
  Future<TaskModel?> getCachedTask(int id) async {
    try {
      final taskMap = await databaseHelper.getTaskById(id);
      if (taskMap == null) return null;

      return TaskModel.fromJson(taskMap);
    } catch (e) {
      throw CacheException('Failed to get cached task: $e');
    }
  }
}