import '../../domain/entities/note.dart';

// NoteModel - ใช้แปลงข้อมูลระหว่าง Database กับ Entity
class NoteModel extends Note {
  const NoteModel({
    super.id,
    required super.title,
    required super.content,
    super.imagePath,
    super.aiSummary,
    required super.createdAt,
    required super.updatedAt,
  });

  // แปลงจาก Map (SQLite) → NoteModel
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      imagePath: map['image_path'] as String?,
      aiSummary: map['ai_summary'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // แปลงจาก NoteModel → Map (เพื่อบันทึกลง SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'image_path': imagePath,
      'ai_summary': aiSummary,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // แปลงจาก JSON (API response) → NoteModel
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      imagePath: json['image_path'] as String?,
      aiSummary: json['ai_summary'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // แปลงจาก NoteModel → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_path': imagePath,
      'ai_summary': aiSummary,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // แปลงจาก Note entity → NoteModel
  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      imagePath: note.imagePath,
      aiSummary: note.aiSummary,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }
}