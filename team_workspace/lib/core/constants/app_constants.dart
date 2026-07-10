class AppConstants {
  static const String appName = 'Team Workspace';

  // API Endpoints
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String tasksEndpoint = '/todos';
  static const String usersEndpoint = '/users';

  // Local Storage Keys
  static const String userSessionKey = 'user_session';
  static const String tasksListKey = 'tasks_list';
  static const String authTokenKey = 'auth_token';

  // Pagination
  static const int itemsPerPage = 10;

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
}

class TaskStatus {
  static const String pending = 'Pending';
  static const String inProgress = 'In Progress';
  static const String completed = 'Completed';

  static const List<String> all = [pending, inProgress, completed];
}

class TaskPriority {
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';

  static const List<String> all = [low, medium, high];
}