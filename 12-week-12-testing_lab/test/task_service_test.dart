import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/task_repository.dart';

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({this.tasks = const [], this.error});

  final List<String> tasks;
  final Exception? error;

  @override
  Future<List<String>> getTasks() async {
    if (error != null) throw error!;
    return tasks;
  }
}

void main() {
  group('TaskService', () {
    test('meneruskan data dari repository', () async {
      final service = TaskService(
        FakeTaskRepository(tasks: ['Baca materi']),
      );

      expect(await service.loadTasks(), ['Baca materi']);
    });

    test('mengembalikan daftar kosong jika repository kosong', () async {
      final service = TaskService(FakeTaskRepository());

      expect(await service.loadTasks(), isEmpty);
    });

    test('melempar error, bukan diam-diam jadi daftar kosong', () async {
      final service = TaskService(
        FakeTaskRepository(error: Exception('Gagal memuat')),
      );

      expect(service.loadTasks(), throwsA(isA<Exception>()));
    });
  });
}
