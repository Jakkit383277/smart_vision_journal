import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class UpdateNote extends UseCase<Note, UpdateNoteParams> {
  final NoteRepository repository;

  UpdateNote(this.repository);

  @override
  Future<Either<Failure, Note>> call(UpdateNoteParams params) {
    return repository.updateNote(params.note);
  }
}

class UpdateNoteParams {
  final Note note;
  const UpdateNoteParams({required this.note});
}