import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/translation_model.dart';

class HistoryRepository {
  final Dio _dio = ApiClient.instance;

  Future<TranslationModel> saveTranslation({
    required String inputType,
    required String detectedSigns,
    required String resultText,
    double? confidence,
    int? durationMs,
  }) async {
    final response = await _dio.post(
      '/translations/',
      data: {
        'input_type': inputType,
        'detected_signs': detectedSigns,
        'result_text': resultText,
        if (confidence != null) 'confidence': confidence,
        if (durationMs != null) 'duration_ms': durationMs,
      },
    );
    return TranslationModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TranslationModel>> getTranslations({
    int skip = 0,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/translations/',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    final list = response.data['translations'] as List;
    return list
        .map((e) => TranslationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteTranslation(int id) async {
    await _dio.delete('/translations/$id');
  }
}
