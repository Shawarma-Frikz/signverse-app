import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class PredictionResult {
  final String label;
  final double confidence;
  final List<PredictionCandidate> top5;

  const PredictionResult({
    required this.label,
    required this.confidence,
    required this.top5,
  });

  factory PredictionResult.fromAlphabetJson(Map<String, dynamic> json) =>
      PredictionResult(
        label: json['letter'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        top5: (json['top5'] as List)
            .map(
              (e) => PredictionCandidate(
                label: e['letter'] as String,
                confidence: (e['confidence'] as num).toDouble(),
              ),
            )
            .toList(),
      );
}

class PredictionCandidate {
  final String label;
  final double confidence;
  const PredictionCandidate({required this.label, required this.confidence});
}

class PredictionService {
  PredictionService._();
  static final PredictionService instance = PredictionService._();

  final Dio _dio = ApiClient.instance;

  // ── Throttle ───────────────────────────────────────────────────
  DateTime _lastCall = DateTime.fromMillisecondsSinceEpoch(0);
  static const _minIntervalMs = 150;

  bool get _canCall =>
      DateTime.now().difference(_lastCall).inMilliseconds >= _minIntervalMs;

  // ── Alphabet prediction ────────────────────────────────────────
  // Accepts a single frame of 63 landmark values
  Future<PredictionResult?> predictAlphabet(List<double> landmarks) async {
    if (!_canCall) return null;
    if (landmarks.length != 63) return null;

    _lastCall = DateTime.now();

    try {
      final response = await _dio.post(
        '/predict/alphabet',
        data: {'landmarks': landmarks},
      );
      return PredictionResult.fromAlphabetJson(
        response.data as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
