import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

// ยังไม่ได้ทำอะไร
class NoteInitial extends NoteState {
  const NoteInitial();
}

// กำลังโหลด
class NoteLoading extends NoteState {
  const NoteLoading();
}

// โหลดสำเร็จ
class NoteLoaded extends NoteState {
  final List<Note> notes;
  const NoteLoaded({required this.notes});

  @override
  List<Object?> get props => [notes];
}

// เกิด error
class NoteError extends NoteState {
  final String message;
  const NoteError({required this.message});

  @override
  List<Object?> get props => [message];
}

// กำลังสรุปด้วย AI
class NoteSummarizing extends NoteState {
  final List<Note> notes;
  const NoteSummarizing({required this.notes});

  @override
  List<Object?> get props => [notes];
}

// สรุปสำเร็จ
class NoteSummarized extends NoteState {
  final List<Note> notes;
  final String summary;
  const NoteSummarized({required this.notes, required this.summary});

  @override
  List<Object?> get props => [notes, summary];
}