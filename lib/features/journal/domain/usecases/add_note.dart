import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class AddNote extends UseCase<Note, AddNoteParams> {
  final NoteRepository repository;

  AddNote(this.repository);

  @override
  Future<Either<Failure, Note>> call(AddNoteParams params) {
    return repository.addNote(params.note);
  }
}

class AddNoteParams {
  final Note note;
  const AddNoteParams({required this.note});
}