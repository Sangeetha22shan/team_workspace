import 'package:flutter/material.dart';
import 'package:team_workspace/injection/service_locator.dart';
import '../../data/datasource/local_task_datasource.dart';
import '../../data/models/task_model.dart';

class LocalTasksDebugPage extends StatefulWidget {
  const LocalTasksDebugPage({Key? key}) : super(key: key);

  @override
  State<LocalTasksDebugPage> createState() => _LocalTasksDebugPageState();
}

class _LocalTasksDebugPageState extends State<LocalTasksDebugPage> {
  final LocalTaskDataSource _local = getIt<LocalTaskDataSource>();
  List<TaskModel> _tasks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await _local.getCachedTasks();
      setState(() => _tasks = tasks);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Tasks (Debug)'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error: $_error', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                      )
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final t = _tasks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text('#${t.id} ${t.title}', style: TextStyle(color: theme.textTheme.titleMedium?.color)),
                          subtitle: Text('${t.priority} • ${t.status} • Due ${t.dueDate.toIso8601String()}', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
