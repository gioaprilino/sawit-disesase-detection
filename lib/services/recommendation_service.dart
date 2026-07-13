import 'dart:convert';

import 'package:flutter/services.dart';

class Recommendation {
  final String name;
  final String description;
  final String severity;
  final List<String> treatments;
  final List<String> preventions;

  Recommendation({
    required this.name,
    required this.description,
    required this.severity,
    required this.treatments,
    required this.preventions,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      name: json['name'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      treatments: List<String>.from(json['treatments'] as List),
      preventions: List<String>.from(json['preventions'] as List),
    );
  }
}

class RecommendationService {
  static const String _path = 'assets/recommendations.json';
  Map<String, Recommendation>? _data;

  Future<void> load() async {
    final jsonStr = await rootBundle.loadString(_path);
    final Map<String, dynamic> jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
    _data = jsonMap.map((key, value) => MapEntry(key, Recommendation.fromJson(value as Map<String, dynamic>)));
  }

  Recommendation? get(String diseaseClass) {
    if (_data == null) return null;
    return _data![diseaseClass];
  }

  bool get isLoaded => _data != null;
}
