List<T> filterNotesByTitle<T>(
  Iterable<T> notes,
  String query, {
  required String Function(T) titleOf,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return notes.toList();

  return notes
      .where((note) => titleOf(note).toLowerCase().contains(normalizedQuery))
      .toList();
}
