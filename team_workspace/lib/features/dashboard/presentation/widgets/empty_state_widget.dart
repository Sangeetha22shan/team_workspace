import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool hasSearchQuery;

  const EmptyStateWidget({
    Key? key,
    this.hasSearchQuery = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchQuery
                ? 'Try adjusting your search or filters'
                : 'No tasks available at the moment',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

