/// Resolves a display name from an already-loaded list by ID.
/// Falls back to `fallback` when the ID is empty, not found, or the
/// name is blank — so renames show up everywhere and a still-loading
/// list or deleted record never breaks the UI.
String resolveLeadName<T>({
  required List<T> list,
  required String id,
  required String fallback,
  required String Function(T item) idOf,
  required String Function(T item) nameOf,
}) {
  if (id.isEmpty) return fallback;
  for (final item in list) {
    if (idOf(item) == id) {
      final name = nameOf(item);
      return name.isEmpty ? fallback : name;
    }
  }
  return fallback;
}


