import 'dart:io';
import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/detection_record.dart';

class HistoryService {
  static const String _boxName = 'history';

  Future<Box> get _box async => Hive.openBox(_boxName);

  Future<String> _generateId() async {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}_${now.microsecond}';
  }

  Future<String> saveImage(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> save(DetectionRecord record) async {
    final box = await _box;
    await box.put(record.id, record.toMap());
  }

  Future<void> saveNew({
    required Uint8List imageBytes,
    required String label,
    required double confidence,
    required List<double> probabilities,
    String? diseaseName,
    String? severity,
  }) async {
    final id = await _generateId();
    final imagePath = await saveImage(imageBytes);
    final record = DetectionRecord(
      id: id,
      imagePath: imagePath,
      label: label,
      confidence: confidence,
      probabilities: probabilities,
      timestamp: DateTime.now(),
      diseaseName: diseaseName,
      severity: severity,
    );
    await save(record);
  }

  Future<List<DetectionRecord>> getAll() async {
    final box = await _box;
    final records = <DetectionRecord>[];
    for (final key in box.keys) {
      final map = box.get(key) as Map?;
      if (map != null) {
        records.add(DetectionRecord.fromMap(map.cast<String, dynamic>()));
      }
    }
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  Future<DetectionRecord?> getById(String id) async {
    final box = await _box;
    final map = box.get(id) as Map?;
    if (map == null) return null;
    return DetectionRecord.fromMap(map.cast<String, dynamic>());
  }

  Future<void> delete(String id) async {
    final box = await _box;
    final record = await getById(id);
    if (record != null) {
      await deleteImage(record.imagePath);
    }
    await box.delete(id);
  }

  Future<void> clear() async {
    final box = await _box;
    final records = await getAll();
    for (final record in records) {
      await deleteImage(record.imagePath);
    }
    await box.clear();
  }

  Future<int> count() async {
    final box = await _box;
    return box.length;
  }
}
