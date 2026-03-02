import 'package:equatable/equatable.dart';

// Base class สำหรับ Error ทุกประเภทในแอป
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

// เกิดจาก SQLite
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}

// เกิดจาก Hive cache
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

// เกิดจาก Dio / API call
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

// เกิดจาก ML Kit OCR
class OcrFailure extends Failure {
  const OcrFailure({required super.message});
}

// เกิดจาก Gemini API
class AiFailure extends Failure {
  const AiFailure({required super.message});
}