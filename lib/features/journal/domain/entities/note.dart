import 'package:equatable/equatable.dart';

// Note entity - หัวใจของแอป (pure Dart ไม่มี dependency อื่น)
class Note extends Equatable {
  final int? id;
  final String title;
  final String content;
  final String? imagePath;
  final String? aiSummary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    this.id,
    required this.title,
    required this.content,
    this.imagePath,
    this.aiSummary,
    required this.createdAt,
    required this.updatedAt,
  });

  // copyWith - ใช้ตอนแก้ไขข้อมูลบางส่วน
  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? imagePath,
    String? aiSummary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      aiSummary: aiSummary ?? this.aiSummary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        imagePath,
        aiSummary,
        createdAt,
        updatedAt,
      ];
}