import 'package:flutter_test/flutter_test.dart';

import 'package:sawit_app/models/detection_record.dart';

void main() {
  group('DetectionRecord', () {
    test('toMap and fromMap roundtrip', () {
      final record = DetectionRecord(
        id: 'test_001',
        imagePath: '/path/to/image.png',
        label: 'normal',
        confidence: 0.95,
        probabilities: [0.02, 0.01, 0.01, 0.01, 0.0, 0.95],
        timestamp: DateTime(2026, 7, 1, 10, 30),
        diseaseName: 'Sehat',
        severity: 'tidak_ada',
      );

      final map = record.toMap();
      final restored = DetectionRecord.fromMap(map);

      expect(restored.id, record.id);
      expect(restored.imagePath, record.imagePath);
      expect(restored.label, record.label);
      expect(restored.confidence, record.confidence);
      expect(restored.probabilities, record.probabilities);
      expect(restored.timestamp, record.timestamp);
      expect(restored.diseaseName, record.diseaseName);
      expect(restored.severity, record.severity);
    });
  });
}
