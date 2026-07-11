import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_workspace/core/constants/app_constants.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:team_workspace/core/theme/theme_cubit.dart';
import 'package:team_workspace/features/dashboard/presentation/pages/task_detail_page.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_card.dart';
import '../widgets/search_tasks_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/offline_error_state_widget.dart';
import '../widgets/empty_state_widget.dart';
import 'create_task_page.dart';


class DashboardPage extends StatefulWidget {
  final bool isOnline;

  const DashboardPage({Key? key, this.isOnline = true}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  late final GlobalKey<SearchTasksWidgetState> _searchWidgetKey;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _searchWidgetKey = GlobalKey<SearchTasksWidgetState>();

    _scrollController.addListener(_onScroll);
    context.read<TaskBloc>().add(const GetTasksEvent(lastId: 0, limit: AppConstants.itemsPerPage));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

   void _onScroll() {
     // Load more when scrolling to the bottom (to get older tasks in descending order)
     if (_scrollController.position.pixels ==
         _scrollController.position.maxScrollExtent) {
       _loadMoreTasks();
     }
   }

    void _loadMoreTasks() {
      // don't load during search
      if (_searchController.text.isNotEmpty) return;
      final state = context.read<TaskBloc>().state;

      if (state is! TaskLoadedState || state.hasReachedMax) return;

      // Use the first (oldest) task's id to load older tasks
      context.read<TaskBloc>().add(
        GetTasksEvent(lastId: state.tasks.isNotEmpty ? state.tasks.last.id : 0, limit: AppConstants.itemsPerPage),
      );
    }

    Future<void> _onRefresh() async {
      // Clear search text and filters
      _searchController.clear();
      _searchWidgetKey.currentState?.clearFilters();

      // Reset and reload tasks
      context.read<TaskBloc>().add(const ResetTasksEvent());
      context.read<TaskBloc>().add(
        const GetTasksEvent(lastId: 0, limit: AppConstants.itemsPerPage),
      );
    }

  void _handleSearch() {
    final statusFilter = _searchWidgetKey.currentState?.selectedStatus;
    final priorityFilter = _searchWidgetKey.currentState?.selectedPriority;

    if (_searchController.text.isEmpty &&
        statusFilter == null &&
        priorityFilter == null) {
      context.read<TaskBloc>().add(const ResetTasksEvent());
      context.read<TaskBloc>().add(
        const GetTasksEvent(lastId: 0, limit: AppConstants.itemsPerPage),
      );
    } else {
      context.read<TaskBloc>().add(
        SearchTasksEvent(
          query: _searchController.text,
          statusFilter: statusFilter,
          priorityFilter: priorityFilter,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Open create task form
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateTaskPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          // Theme toggle
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                onPressed: () {
                  // Toggle between light and dark. If currently system, switch to dark.
                  if (mode == ThemeMode.dark) {
                    context.read<ThemeCubit>().setDarkMode(false);
                  } else {
                    context.read<ThemeCubit>().setDarkMode(true);
                  }
                },
              );
            },
          ),
          // Debug button removed per user request
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutEvent());
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline indicator (provided by parent)
          if (!widget.isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange,
              child: Row(
                children: [
                  const Icon(Icons.cloud_off, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Offline - Showing cached data',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Search Widget
          SearchTasksWidget(
            key: _searchWidgetKey,
            searchController: _searchController,
            onSearchChanged: _handleSearch,
          ),
          // Tasks list
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskInitialState || state is TaskLoadingState) {
                  if (state is TaskInitialState) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is TaskLoadedState) {
                  if (state.tasks.isEmpty) {
                    return EmptyStateWidget(
                      hasSearchQuery: _searchController.text.isNotEmpty,
                    );
                  }

                  return _buildTasksList(state.tasks, isLoadingMore: state.isLoadingMore);
                }

                if (state is TaskErrorState) {
                  return ErrorStateWidget(
                    message: state.message,
                    code: state.code,
                    onRetry: () {
                      context.read<TaskBloc>().add(
                        const GetTasksEvent(
                          lastId: 0,
                          limit: AppConstants.itemsPerPage,
                        ),
                      );
                    },
                  );
                }

                if (state is TaskOfflineState) {
                  return OfflineErrorStateWidget(message: state.message);
                }

                return EmptyStateWidget(
                  hasSearchQuery: _searchController.text.isNotEmpty,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildTasksList(List<Task> tasks, {bool isLoadingMore = false}) {
     return Stack(
       children: [
         RefreshIndicator(
           onRefresh: _onRefresh,
           child: ListView.builder(
             controller: _scrollController,
             padding: const EdgeInsets.all(16),
             itemCount: tasks.length + (isLoadingMore ? 1 : 0),
             itemBuilder: (context, index) {
               if (isLoadingMore && index == tasks.length) {
                 return Padding(
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   child: const Center(
                     child: CircularProgressIndicator(),
                   ),
                 );
               }

               final task = tasks[index];
               return TaskCard(
                 task: task,
                 onTap: () {
                   Navigator.of(context).push(
                     MaterialPageRoute(
                       builder: (context) => TaskDetailPage(task: task),
                     ),
                   );
                 },
               );
             },
           ),
         ),
       ],
     );
   }
}