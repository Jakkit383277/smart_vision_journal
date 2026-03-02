import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/note_repository.dart';

class SummarizeNote extends UseCase<String, SummarizeNoteParams> {
  final NoteRepository repository;

  SummarizeNote(this.repository);

  @override
  Future<Either<Failure, String>> call(SummarizeNoteParams params) {
    return repository.summarizeWithAI(params.text);
  }
}

class SummarizeNoteParams {
  final String text;
  const SummarizeNoteParams({required this.text});
}