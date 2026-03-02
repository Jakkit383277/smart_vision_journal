import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/cache_data_source.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;
  final NoteCacheDataSource cacheDataSource;
  final NoteRemoteDataSource remoteDataSource;

  NoteRepositoryImpl({
    required this.localDataSource,
    required this.cacheDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Note>>> getAllNotes() async {
    try {
      // ดึงจาก SQLite ก่อน (Offline-first)
      final notes = await localDataSource.getAllNotes();
      // Cache ผลลัพธ์ไว้ใน Hive
      await cacheDataSource.cacheNotes(notes);
      return Right(notes);
    } on DatabaseFailure catch (e) {
      // ถ้า DB fail ลอง fallback ไป cache
      try {
        final cached = await cacheDataSource.getCachedNotes();
        return Right(cached);
      } on CacheFailure {
        return Left(e);
      }
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Note>> addNote(Note note) async {
    try {
      final model = NoteModel.fromEntity(note);
      final saved = await localDataSource.insertNote(model);
      return Right(saved);
    } on DatabaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Note>> updateNote(Note note) async {
    try {
      final model = NoteModel.fromEntity(note);
      final updated = await localDataSource.updateNote(model);
      return Right(updated);
    } on DatabaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNote(int id) async {
    try {
      final result = await localDataSource.deleteNote(id);
      return Right(result);
    } on DatabaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> summarizeWithAI(String text) async {
    try {
      final summary = await remoteDataSource.summarizeText(text);
      return Right(summary);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on AiFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AiFailure(message: e.toString()));
    }
  }
}