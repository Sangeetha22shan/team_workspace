import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/network/network_info.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/dashboard_usecase.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class GetTasksEvent extends TaskEvent {
  final int? page;
  final int limit;
  final int? lastId;

  const GetTasksEvent({
    this.page,
    required this.limit,
    this.lastId,
  });

  @override
  List<Object?> get props => [page, limit, lastId];
}



class SearchTasksEvent extends TaskEvent {
  final String query;
  final String? statusFilter;
  final String? priorityFilter;

  const SearchTasksEvent({
    required this.query,
    this.statusFilter,
    this.priorityFilter,
  });

  @override
  List<Object?> get props => [query, statusFilter, priorityFilter];
}

class ResetTasksEvent extends TaskEvent {
  const ResetTasksEvent();
}

class ConnectivityChangedEvent extends TaskEvent {
  final bool isConnected;

  const ConnectivityChangedEvent(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}

// States
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitialState extends TaskState {
  const TaskInitialState();
}

class TaskLoadingState extends TaskState {
  const TaskLoadingState();
}

class TaskLoadedState extends TaskState {
  final List<Task> tasks;
  final bool hasReachedMax;
  final int currentPage;
  final bool isLoadingMore;

  const TaskLoadedState({
    required this.tasks,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  TaskLoadedState copyWith({
    List<Task>? tasks,
    bool? hasReachedMax,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return TaskLoadedState(
      tasks: tasks ?? this.tasks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [tasks, hasReachedMax, currentPage, isLoadingMore];
}

class TaskErrorState extends TaskState {
  final String message;
  final String? code;

  const TaskErrorState({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class TaskOfflineState extends TaskState {
  final String message;

  const TaskOfflineState({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final DashboardUseCase dashboardUseCase;
  final NetworkInfo networkInfo;


  TaskBloc({
    required this.dashboardUseCase,
    required this.networkInfo,
  }) : super(const TaskInitialState()) {
    on<GetTasksEvent>(_onGetTasks);
    on<SearchTasksEvent>(_onSearchTasks);
    on<ResetTasksEvent>(_onReset);
    on<ConnectivityChangedEvent>(_onConnectivityChanged);
    
    // Listen to connectivity changes
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    networkInfo.onConnectivityChanged.listen((isConnected) {
      add(ConnectivityChangedEvent(isConnected));
    });
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChangedEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (event.isConnected && state is TaskLoadedState) {
      // When connection is restored and we have cached data, try to refresh
      final currentState = state as TaskLoadedState;
      emit(
        TaskLoadedState(
          tasks: currentState.tasks,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
        ),
      );
    }
  }

     Future<void> _onGetTasks(
         GetTasksEvent event,
         Emitter<TaskState> emit,
         ) async {
       if (state is TaskLoadedState) {
         final currentState = state as TaskLoadedState;
         if (currentState.hasReachedMax) return;
         // Show loading indicator for pagination
         emit(currentState.copyWith(isLoadingMore: true));
       }

       // Only emit loading state when we don't already have loaded tasks
       if (state is! TaskLoadedState) {
         emit(const TaskLoadingState());
       }

       final result = await dashboardUseCase.getTasks(
         page: event.page,
         limit: event.limit,
         lastId: event.lastId,
       );

        result.fold(
              (failure) => emit(
            TaskErrorState(
              message: failure.message,
              code: failure.code,
            ),
          ),
              (List<Task> tasks) {
            if (state is TaskLoadedState) {
              final currentState = state as TaskLoadedState;
              // Append new tasks to existing tasks (newest first pagination)
              final updatedTasks = [...currentState.tasks, ...tasks];
               emit(
                   TaskLoadedState(
                   tasks: updatedTasks,
                   // If returned list is smaller than requested limit, we've reached the end
                   hasReachedMax: tasks.isEmpty || tasks.length < event.limit,
                   currentPage: event.page ?? 1,
                   isLoadingMore: false,
                 ),
               );
            } else {
               // Load tasks in newest-first order (already ordered by database)
               emit(
                 TaskLoadedState(
                   tasks: tasks,
                   // If returned list is smaller than requested limit, we've reached the end
                   hasReachedMax: tasks.isEmpty || tasks.length < event.limit,
                   currentPage: event.page ?? 1,
                   isLoadingMore: false,
                 ),
               );
            }
          },
        );
     }


     Future<void> _onSearchTasks(
         SearchTasksEvent event,
         Emitter<TaskState> emit,
         ) async {
       emit(const TaskLoadingState());

       final result = await dashboardUseCase.searchTasks(
         query: event.query,
         statusFilter: event.statusFilter,
         priorityFilter: event.priorityFilter,
       );

        result.fold(
              (failure) => emit(
            TaskErrorState(
              message: failure.message,
              code: failure.code,
            ),
          ),
              (List<Task> tasks) => emit(
            TaskLoadedState(
              tasks: tasks,
              hasReachedMax: true,
              currentPage: 1,
            ),
          ),
        );
     }

  Future<void> _onReset(
      ResetTasksEvent event,
      Emitter<TaskState> emit,
      ) async {
    emit(const TaskInitialState());
  }
}