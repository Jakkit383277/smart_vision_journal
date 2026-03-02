import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

// โหลด note ทั้งหมด
class LoadNotes extends NoteEvent {
  const LoadNotes();
}

// เพิ่ม note ใหม่
class AddNoteEvent extends NoteEvent {
  final Note note;
  const AddNoteEvent({required this.note});

  @override
  List<Object?> get props => [note];
}

// แก้ไข note
class UpdateNoteEvent extends NoteEvent {
  final Note note;
  const UpdateNoteEvent({required this.note});

  @override
  List<Object?> get props => [note];
}

// ลบ note
class DeleteNoteEvent extends NoteEvent {
  final int id;
  const DeleteNoteEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// สรุปด้วย AI
class SummarizeNoteEvent extends NoteEvent {
  final int noteId;
  final String content;
  const SummarizeNoteEvent({required this.noteId, required this.content});

  @override
  List<Object?> get props => [noteId, content];
}