import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/error/failures.dart';

abstract class NoteRemoteDataSource {
  Future<String> summarizeText(String text);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final Dio dio;
  NoteRemoteDataSourceImpl(this.dio);

  // ใส่ KEY ใหม่ตรงนี้
  static const String _apiKey = 'your_real_key_here';

  @override
  Future<String> summarizeText(String text) async {
    const model = 'gemini-2.0-flash';
    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'text':
                  'สรุปข้อความต่อไปนี้เป็นภาษาไทย ให้กระชับ ไม่เกิน 3 ประโยค:\n\n$text'
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 500,
      }
    });

    debugPrint('🤖 Calling Gemini ($model)...');

    try {
      if (kIsWeb) {
        // Web: ใช้ http package แทน dio เพื่อหลีกเลี่ยง CORS
        final response = await http
            .post(
              Uri.parse('$url?key=$_apiKey'),
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final candidates = data['candidates'] as List;
          if (candidates.isEmpty) {
            throw const AiFailure(message: 'AI ไม่มี response');
          }
          final result = candidates[0]['content']['parts'][0]['text'] as String;
          debugPrint('✅ Gemini OK!');
          return result;
        }
        _handleStatusCode(response.statusCode);
      } else {
        // Mobile: ใช้ dio ตามปกติ
        final response = await dio.post(
          '$url?key=$_apiKey',
          data: body,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        if (response.statusCode == 200) {
          final candidates = response.data['candidates'] as List;
          if (candidates.isEmpty) {
            throw const AiFailure(message: 'AI ไม่มี response');
          }
          final result = candidates[0]['content']['parts'][0]['text'] as String;
          debugPrint('✅ Gemini OK!');
          return result;
        }
      }

      throw const AiFailure(message: 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ');
    } on DioException catch (e) {
      _handleStatusCode(e.response?.statusCode);
      throw NetworkFailure(message: 'Network error: ${e.message}');
    } catch (e) {
      if (e is AiFailure || e is NetworkFailure) rethrow;
      throw AiFailure(message: 'Error: $e');
    }
  }

  Never _handleStatusCode(int? status) {
    if (status == 400) throw const AiFailure(message: 'Request ผิดพลาด');
    if (status == 403) throw const AiFailure(message: 'API Key ถูก revoke');
    if (status == 404) throw const AiFailure(message: 'ไม่พบ Model');
    if (status == 429) throw const AiFailure(message: 'Quota หมด ลองใหม่');
    throw AiFailure(message: 'API error: $status');
  }
}
