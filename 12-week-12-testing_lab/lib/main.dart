import 'package:flutter/material.dart';
import 'package:testing_lab/is_valid_task_title.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: TaskPage());
  }
}

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _controller = TextEditingController();
  final _tasks = <String>[];
  String? _errorText;

  void _save() {
    final title = _controller.text;
    setState(() {
      if (!isValidTaskTitle(title)) {
        _errorText = 'Judul tugas tidak boleh kosong';
        return;
      }
      _tasks.add(title.trim());
      _controller.clear();
      _errorText = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('task-title-field'),
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Judul tugas',
                errorText: _errorText,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              key: const Key('save-task-button'),
              onPressed: _save,
              child: const Text('Simpan'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(child: Text('Belum ada tugas'))
                  : ListView(
                      children: [
                        for (final task in _tasks) ListTile(title: Text(task)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
