import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/connectivity_provider.dart';
import '../providers/notes_provider.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyCountAsync = ref.watch(dirtyCountProvider);
    final forceOffline = ref.watch(forceOfflineProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    ref.listen(syncStatusProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync gagal: $err')),
        ),
        data: (count) {
          if (count > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$count catatan tersinkron')),
            );
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            tooltip: forceOffline ? 'Simulasi: Offline' : 'Simulasi: Online',
            icon: Icon(forceOffline ? Icons.cloud_off : Icons.cloud_done),
            onPressed: () => ref.read(forceOfflineProvider.notifier).state =
                !forceOffline,
          ),
          dirtyCountAsync.maybeWhen(
            data: (count) => count == 0
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      child: Badge(
                        label: Text('$count'),
                        child: const Icon(Icons.sync_problem),
                      ),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Sinkronkan',
            icon: syncStatus.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: syncStatus.isLoading
                ? null
                : () => ref.read(syncStatusProvider.notifier).syncNow(),
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) => notes.isEmpty
            ? const Center(child: Text('Belum ada catatan'))
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.body),
                    leading: Icon(
                      Icons.circle,
                      size: 10,
                      color: note.dirty ? Colors.orange : Colors.green,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          ref.read(notesProvider.notifier).remove(note.id!),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catatan baru'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      await ref.read(notesProvider.notifier).add(result.trim());
    }
  }
}