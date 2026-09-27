import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../local/note.dart';

class NoteRepository {
  static const _notesKey = 'offline_notes';

  Future<List<Note>> fetchNotes() async {
    final prefs = await SharedPreferences.getInstance();
    return _read(prefs);
  }

  Future<Note> addNote({required String title, String body = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = _read(prefs);
    final nextId = notes.fold<int>(0, (maxId, note) {
      return note.id != null && note.id! > maxId ? note.id! : maxId;
    }) + 1;
    final note = Note(
      id: nextId,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    await _write(prefs, [...notes, note]);
    return note;
  }

  Future<void> deleteNote(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await _write(prefs, _read(prefs).where((note) => note.id != id).toList());
  }

  Future<int> countDirty() async {
    final prefs = await SharedPreferences.getInstance();
    return _read(prefs).where((note) => note.dirty).length;
  }

  Future<void> markAllSynced() async {
    final prefs = await SharedPreferences.getInstance();
    await _write(
      prefs,
      _read(prefs)
          .map((note) => Note(
                id: note.id,
                title: note.title,
                body: note.body,
                updatedAt: note.updatedAt,
              ))
          .toList(),
    );
  }

  List<Note> _read(SharedPreferences prefs) {
    final raw = prefs.getString(_notesKey);
    if (raw == null) return [];
    final values = (jsonDecode(raw) as List).cast<Map<String, Object?>>();
    final notes = values.map(Note.fromMap).toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Future<void> _write(SharedPreferences prefs, List<Note> notes) {
    return prefs.setString(
      _notesKey,
      jsonEncode(notes.map((note) => note.toMap()).toList()),
    );
  }
}
