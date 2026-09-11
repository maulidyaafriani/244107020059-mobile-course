import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'stats_notifier.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
              ),
              const SizedBox(height: 12),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(statsProvider.notifier).retry();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (stats) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final item = stats[index];

            return Card(
              child: ListTile(
                leading: const Icon(Icons.bar_chart),
                title: Text(item.title),
                trailing: Text(
                  item.value.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go('/');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'Todo',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }
}