import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:team_workspace/features/dashboard/domain/entities/task.dart';
import 'package:team_workspace/features/dashboard/domain/usecases/dashboard_usecase.dart';
import 'package:team_workspace/features/dashboard/presentation/bloc/task_bloc.dart';

class MockDashboardUseCase extends Mock implements DashboardUseCase {}

void main() {
  late TaskBloc taskBloc;
  late MockDashboardUseCase mockDashboardUseCase;

  setUp(() {
    mockDashboardUseCase = MockDashboardUseCase();
    taskBloc = TaskBloc(dashboardUseCase: mockDashboardUseCase);
  });

  tearDown(() {
    taskBloc.close();
  });

  group('TaskBloc - Get Tasks List', () {
    blocTest<TaskBloc, TaskState>(
      'loads and displays list of tasks',
      build: () {
        final tasks = [
          Task(
            id: 1,
            title: 'Task 1',
            description: 'Description 1',
            priority: 'High',
            status: 'Pending',
            dueDate: DateTime(2024, 12, 31),
            assignedTo: 'John Doe',
          ),
          Task(
            id: 2,
            title: 'Task 2',
            description: 'Description 2',
            priority: 'Medium',
            status: 'Completed',
            dueDate: DateTime(2024, 11, 30),
            assignedTo: 'Jane Smith',
          ),
          Task(
            id: 3,
            title: 'Task 3',
            description: 'Description 3',
            priority: 'Low',
            status: 'In Progress',
            dueDate: DateTime(2024, 12, 15),
            assignedTo: 'Mike Johnson',
          ),
        ];

        when(
          () => mockDashboardUseCase.getTasks(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            lastId: any(named: 'lastId'),
          ),
        ).thenAnswer((_) async => Right(tasks));

        return taskBloc;
      },
      act: (bloc) => bloc.add(const GetTasksEvent(limit: 10)),
      expect: () => [
        const TaskLoadingState(),
        isA<TaskLoadedState>()
            .having((state) => state.tasks.length, 'tasks count', 3)
            .having((state) => state.tasks[0].title, 'first task', 'Task 1')
            .having((state) => state.tasks[1].title, 'second task', 'Task 2')
            .having((state) => state.tasks[2].title, 'third task', 'Task 3'),
      ],
    );
  });
}

