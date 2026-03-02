import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../../core/error/failures.dart';
import '../models/note_model.dart';

abstract class NoteLocalDataSource {
  Future<List<NoteModel>> getAllNotes();
  Future<NoteModel> insertNote(NoteModel note);
  Future<NoteModel> updateNote(NoteModel note);
  Future<bool> deleteNote(int id);
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  static Database? _database;

  // Web ใช้ in-memory แทน
  static final List<NoteModel> _webStorage = [];
  static int _webIdCounter = 1;

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_vision_journal.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            image_path TEXT,
            ai_summary TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<NoteModel>> getAllNotes() async {
    try {
      // Web: ใช้ in-memory
      if (kIsWeb) {
        return List.from(_webStorage.reversed);
      }
      final db = await database;
      final maps = await db!.query('notes', orderBy: 'created_at DESC');
      return maps.map((map) => NoteModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to get notes: $e');
    }
  }

  @override
  Future<NoteModel> insertNote(NoteModel note) async {
    try {
      if (kIsWeb) {
        final newNote = NoteModel(
          id: _webIdCounter++,
          title: note.title,
          content: note.content,
          imagePath: note.imagePath,
          aiSummary: note.aiSummary,
          createdAt: note.createdAt,
          updatedAt: note.updatedAt,
        );
        _webStorage.add(newNote);
        return newNote;
      }
      final db = await database;
      final id = await db!.insert(
        'notes',
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return NoteModel.fromMap({...note.toMap(), 'id': id});
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to insert note: $e');
    }
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    try {
      if (kIsWeb) {
        final index = _webStorage.indexWhere((n) => n.id == note.id);
        if (index != -1) _webStorage[index] = note;
        return note;
      }
      final db = await database;
      await db!.update(
        'notes',
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      return note;
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to update note: $e');
    }
  }

  @override
  Future<bool> deleteNote(int id) async {
    try {
      if (kIsWeb) {
        _webStorage.removeWhere((n) => n.id == id);
        return true;
      }
      final db = await database;
      final count = await db!.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to delete note: $e');
    }
  }
}