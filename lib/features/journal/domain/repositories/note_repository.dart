import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note.dart';

// Interface ที่ Data Layer ต้องไป implement
abstract class NoteRepository {
  // ดึง note ทั้งหมด
  Future<Either<Failure, List<Note>>> getAllNotes();

  // เพิ่ม note ใหม่
  Future<Either<Failure, Note>> addNote(Note note);

  // แก้ไข note
  Future<Either<Failure, Note>> updateNote(Note note);

  // ลบ note
  Future<Either<Failure, bool>> deleteNote(int id);

  // สรุปด้วย AI
  Future<Either<Failure, String>> summarizeWithAI(String text);
}