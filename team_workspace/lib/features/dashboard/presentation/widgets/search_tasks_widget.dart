import 'package:flutter/material.dart';
import 'package:team_workspace/core/constants/app_constants.dart';

class SearchTasksWidget extends StatefulWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;

  const SearchTasksWidget({
    Key? key,
    required this.searchController,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  State<SearchTasksWidget> createState() => SearchTasksWidgetState();
}

class SearchTasksWidgetState extends State<SearchTasksWidget> {
  String? _selectedStatus;
  String? _selectedPriority;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: widget.searchController,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (_) => widget.onSearchChanged(),
          ),
        ),
        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              DropdownButton<String?>(
                value: _selectedStatus,
                hint: const Text('Status'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Status'),
                  ),
                  ...TaskStatus.all.map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  widget.onSearchChanged();
                },
              ),
              const SizedBox(width: 12),
              DropdownButton<String?>(
                value: _selectedPriority,
                hint: const Text('Priority'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Priority'),
                  ),
                  ...TaskPriority.all.map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value;
                  });
                  widget.onSearchChanged();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String? get selectedStatus => _selectedStatus;
  String? get selectedPriority => _selectedPriority;

  void clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedPriority = null;
    });
  }
}

