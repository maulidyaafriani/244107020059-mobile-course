import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../domain/use_cases/filter_notes_by_title.dart';
import '../providers/connectivity_provider.dart';
import '../providers/notes_provider.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyCountAsync = ref.watch(dirtyCountProvider);
    final forceOffline = ref.watch(forceOfflineProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    ref.listen(syncStatusProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) =>
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Sync gagal: $err'))),
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
            onPressed: () =>
                ref.read(forceOfflineProvider.notifier).state = !forceOffline,
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
        data: _buildNotes,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNotes(List<Note> notes) {
    if (notes.isEmpty) return const Center(child: Text('Belum ada catatan'));

    final filteredNotes = filterNotesByTitle(
      notes,
      _query,
      titleOf: (note) => note.title,
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            key: const ValueKey('notes-search-field'),
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari judul catatan',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      key: const ValueKey('clear-note-search'),
                      tooltip: 'Hapus pencarian',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.clear),
                    ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: filteredNotes.isEmpty
              ? const Center(child: Text('Tidak ada catatan yang cocok'))
              : ListView.builder(
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
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
        ),
      ],
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
