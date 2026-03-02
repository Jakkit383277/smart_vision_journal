import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/get_all_notes.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/update_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/summarize_note.dart';
import '../../../../core/usecases/usecase.dart';
import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final GetAllNotes getAllNotes;
  final AddNote addNote;
  final UpdateNote updateNote;
  final DeleteNote deleteNote;
  final SummarizeNote summarizeNote;

  NoteBloc({
    required this.getAllNotes,
    required this.addNote,
    required this.updateNote,
    required this.deleteNote,
    required this.summarizeNote,
  }) : super(const NoteInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<SummarizeNoteEvent>(_onSummarizeNote);
  }

  Future<void> _onLoadNotes(
    LoadNotes event,
    Emitter<NoteState> emit,
  ) async {
    emit(const NoteLoading());
    final result = await getAllNotes(NoParams());
    result.fold(
      (failure) => emit(NoteError(message: failure.message)),
      (notes) => emit(NoteLoaded(notes: notes)),
    );
  }

  Future<void> _onAddNote(
    AddNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(const NoteLoading());
    final result = await addNote(AddNoteParams(note: event.note));
    await result.fold(
      (failure) async => emit(NoteError(message: failure.message)),
      (_) async {
        final notesResult = await getAllNotes(NoParams());
        notesResult.fold(
          (failure) => emit(NoteError(message: failure.message)),
          (notes) => emit(NoteLoaded(notes: notes)),
        );
      },
    );
  }

  Future<void> _onUpdateNote(
    UpdateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(const NoteLoading());
    final result = await updateNote(UpdateNoteParams(note: event.note));
    await result.fold(
      (failure) async => emit(NoteError(message: failure.message)),
      (_) async {
        final notesResult = await getAllNotes(NoParams());
        notesResult.fold(
          (failure) => emit(NoteError(message: failure.message)),
          (notes) => emit(NoteLoaded(notes: notes)),
        );
      },
    );
  }

  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(const NoteLoading());
    final result = await deleteNote(DeleteNoteParams(id: event.id));
    await result.fold(
      (failure) async => emit(NoteError(message: failure.message)),
      (_) async {
        final notesResult = await getAllNotes(NoParams());
        notesResult.fold(
          (failure) => emit(NoteError(message: failure.message)),
          (notes) => emit(NoteLoaded(notes: notes)),
        );
      },
    );
  }

  Future<void> _onSummarizeNote(
    SummarizeNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    final currentNotes = state is NoteLoaded
        ? (state as NoteLoaded).notes
        : <Note>[];

    emit(NoteSummarizing(notes: currentNotes));

    final result = await summarizeNote(
      SummarizeNoteParams(text: event.content),
    );

    await result.fold(
      (failure) async => emit(NoteError(message: failure.message)),
      (summary) async {
        final noteIndex = currentNotes.indexWhere(
          (n) => n.id == event.noteId,
        );

        if (noteIndex != -1) {
          final updatedNote = currentNotes[noteIndex].copyWith(
            aiSummary: summary,
            updatedAt: DateTime.now(),
          );

          await updateNote(UpdateNoteParams(note: updatedNote));
        }

        final notesResult = await getAllNotes(NoParams());
        notesResult.fold(
          (failure) => emit(NoteError(message: failure.message)),
          (notes) => emit(NoteSummarized(notes: notes, summary: summary)),
        );
      },
    );
  }
}