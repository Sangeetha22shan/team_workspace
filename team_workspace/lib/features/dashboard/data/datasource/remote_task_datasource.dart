import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:team_workspace/core/error/exceptions.dart';
import 'package:team_workspace/core/network/dio_client.dart';

import '../models/task_model.dart';

abstract class RemoteTaskDataSource {
  Future<List<TaskModel>> getTasks({
    required int page,
    required int limit,
  });

  Future<TaskModel> getTaskById(int id);
}

class RemoteTaskDataSourceImpl implements RemoteTaskDataSource {
  final DioClient dioClient;
  final Logger logger;

  RemoteTaskDataSourceImpl({
    required this.dioClient,
    required this.logger,
  });

  @override
  Future<List<TaskModel>> getTasks({
    required int page,
    required int limit,
  }) async {
    try {
      // Fetch all todos from JSONPlaceholder API
      final response = await dioClient.get(
        '/todos',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data as Map)['todos'] ?? [];
        return (data).map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch tasks',
          code: response.statusCode.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Network error',
        code: e.response?.statusCode.toString(),
      );
    } catch (e) {
      logger.e('Error fetching tasks: $e');
      throw ServerException(message: 'An unexpected error occurred');
    }
  }

  @override
  Future<TaskModel> getTaskById(int id) async {
    try {
      final response = await dioClient.get('/todos/$id');

      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Task not found',
          code: response.statusCode.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Network error',
        code: e.response?.statusCode.toString(),
      );
    } catch (e) {
      logger.e('Error fetching task: $e');
      throw ServerException(message: 'An unexpected error occurred');
    }
  }
}