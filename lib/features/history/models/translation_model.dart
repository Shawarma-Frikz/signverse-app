class TranslationModel {
  final int id;
  final String inputType;
  final String detectedSigns;
  final String resultText;
  final double? confidence;
  final int? durationMs;
  final DateTime createdAt;

  const TranslationModel({
    required this.id,
    required this.inputType,
    required this.detectedSigns,
    required this.resultText,
    this.confidence,
    this.durationMs,
    required this.createdAt,
  });

  factory TranslationModel.fromJson(Map<String, dynamic> json) =>
      TranslationModel(
        id: json['id'] as int,
        inputType: json['input_type'] as String,
        detectedSigns: json['detected_signs'] as String,
        resultText: json['result_text'] as String,
        confidence: (json['confidence'] as num?)?.toDouble(),
        durationMs: json['duration_ms'] as int?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  String get formattedDate {
    final d = createdAt.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String get formattedTime {
    final d = createdAt.toLocal();
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final period = d.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}
