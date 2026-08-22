class PredictionResult {
  const PredictionResult({
    required this.model,
    required this.disease,
    required this.confidence,
    required this.status,
    required this.recommendation,
    required this.treatment,
    required this.treatmentSource,
    required this.responseTime,
    required this.cpu,
    required this.ram,
    required this.modelSize,
  });

  final String model;
  final String disease;
  final double confidence;
  final String status;
  final String recommendation;
  final String treatment;
  final String treatmentSource;
  final double responseTime;
  final double cpu;
  final double ram;
  final double modelSize;

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return 0;
  }

  factory PredictionResult.fromJson(Map<String, dynamic> json, String model) {
    final detection = _asMap(json['detection']);
    final traitement = _asMap(json['traitement']);
    final performance = _asMap(json['performance']);

    final treatment = (traitement['recommandation'] as String?) ??
        (json['recommandation'] as String?) ??
        '';

    return PredictionResult(
      model: model,
      disease: detection['prediction'] as String? ??
          json['prediction'] as String? ??
          'Unknown',
      confidence: _toDouble(detection['confiance'] ?? json['confiance']),
      status: detection['statut'] as String? ??
          json['statut'] as String? ??
          'Detected',
      recommendation: treatment,
      treatment: treatment,
      treatmentSource: traitement['genere_par'] as String? ?? '',
      responseTime: _toDouble(
        performance['temps_total_secondes'] ??
            performance['temps_detection_secondes'] ??
            json['temps_reponse_secondes'],
      ),
      cpu: _toDouble(performance['cpu_percent'] ?? json['cpu_percent']),
      ram: _toDouble(
        performance['ram_system_percent'] ?? json['ram_percent'],
      ),
      modelSize: _toDouble(
        performance['model_size_mb'] ?? json['model_size_mb'],
      ),
    );
  }
}
