class SensorData {
  final double cervical;
  final double cuello;
  final double lumbar;
  final DateTime timestamp;

  SensorData({
    required this.cervical,
    required this.cuello,
    required this.lumbar,
    required this.timestamp,
  });

  // Esto convierte el JSON que envía la Raspberry a un objeto de Dart
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      cervical: json['cervical']?.toDouble() ?? 0.0,
      cuello: json['cuello']?.toDouble() ?? 0.0,
      lumbar: json['lumbar']?.toDouble() ?? 0.0,
      timestamp: DateTime.now(),
    );
  }
}