class DetectionRecord {
  final String id;
  final String imagePath;
  final String label;
  final double confidence;
  final List<double> probabilities;
  final DateTime timestamp;
  final String? diseaseName;
  final String? severity;

  DetectionRecord({
    required this.id,
    required this.imagePath,
    required this.label,
    required this.confidence,
    required this.probabilities,
    required this.timestamp,
    this.diseaseName,
    this.severity,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'imagePath': imagePath,
    'label': label,
    'confidence': confidence,
    'probabilities': probabilities,
    'timestamp': timestamp.toIso8601String(),
    'diseaseName': diseaseName,
    'severity': severity,
  };

  factory DetectionRecord.fromMap(Map<String, dynamic> map) => DetectionRecord(
    id: map['id'] as String,
    imagePath: map['imagePath'] as String,
    label: map['label'] as String,
    confidence: map['confidence'] as double,
    probabilities: (map['probabilities'] as List).cast<double>(),
    timestamp: DateTime.parse(map['timestamp'] as String),
    diseaseName: map['diseaseName'] as String?,
    severity: map['severity'] as String?,
  );

  DetectionRecord copyWith({String? imagePath}) => DetectionRecord(
    id: id,
    imagePath: imagePath ?? this.imagePath,
    label: label,
    confidence: confidence,
    probabilities: probabilities,
    timestamp: timestamp,
    diseaseName: diseaseName,
    severity: severity,
  );
}
