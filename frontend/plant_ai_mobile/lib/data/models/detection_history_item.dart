import 'dart:typed_data';

class DetectionHistoryItem {
  DetectionHistoryItem({
    required this.id,
    required this.imageBytes,
    required this.detection,
    required this.accuracy,
    required this.model,
    required this.status,
    required this.time,
    required this.modelColor,
    required this.responseTime,
    required this.cpu,
    required this.ram,
  });

  final int id;
  final Uint8List imageBytes;
  final String detection;
  final double accuracy;
  final String model;
  final String status;
  final String time;
  final int modelColor;
  final double responseTime;
  final double cpu;
  final double ram;
}
