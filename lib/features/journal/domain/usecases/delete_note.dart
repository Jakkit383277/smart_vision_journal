import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/note_repository.dart';

class DeleteNote extends UseCase<bool, DeleteNoteParams> {
  final NoteRepository repository;

  DeleteNote(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteNoteParams params) {
    return repository.deleteNote(params.id);
  }
}

class DeleteNoteParams {
  final int id;
  const DeleteNoteParams({required this.id});
}