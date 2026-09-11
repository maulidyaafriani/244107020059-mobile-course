import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Menggunakan provider filter untuk menampilkan
    // hanya Todo yang belum selesai.
    final todos = ref.watch(activeTodosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
      ),
      body: todos.isEmpty
          ? const Center(
              child: Text('Belum ada tugas'),
            )
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];

                return TodoTile(
                  todo: todo,
                  onToggle: () {
                    // Cari index Todo asli berdasarkan object Todo.
                    final allTodos = ref.read(todoListProvider);
                    final originalIndex = allTodos.indexOf(todo);

                    if (originalIndex != -1) {
                      ref
                          .read(todoListProvider.notifier)
                          .toggle(originalIndex);
                    }
                  },
                  onDelete: () {
                    final allTodos = ref.read(todoListProvider);
                    final originalIndex = allTodos.indexOf(todo);

                    if (originalIndex != -1) {
                      ref
                          .read(todoListProvider.notifier)
                          .remove(originalIndex);
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            context.go('/stats');
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

  void _showAddDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Masukkan tugas',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final title = controller.text.trim();

              if (title.isNotEmpty) {
                ref.read(todoListProvider.notifier).add(title);
              }

              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}