import 'package:hive/hive.dart';
import '../../../../core/error/failures.dart';
import '../models/note_model.dart';

abstract class NoteCacheDataSource {
  Future<List<NoteModel>> getCachedNotes();
  Future<void> cacheNotes(List<NoteModel> notes);
}

class NoteCacheDataSourceImpl implements NoteCacheDataSource {
  static const String _cacheKey = 'cached_notes';
  final Box _box;

  NoteCacheDataSourceImpl(this._box);

  @override
  Future<List<NoteModel>> getCachedNotes() async {
    try {
      final cachedData = _box.get(_cacheKey);
      if (cachedData == null) return [];

      final List<dynamic> notesList = cachedData as List<dynamic>;
      return notesList
          .map((e) => NoteModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw CacheFailure(message: 'Failed to get cached notes: $e');
    }
  }

  @override
  Future<void> cacheNotes(List<NoteModel> notes) async {
    try {
      final notesJson = notes.map((note) => note.toJson()).toList();
      await _box.put(_cacheKey, notesJson);
    } catch (e) {
      throw CacheFailure(message: 'Failed to cache notes: $e');
    }
  }
}