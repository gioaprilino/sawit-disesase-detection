import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'services/history_service.dart';
import 'services/recommendation_service.dart';
import 'services/tflite_classifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('history');
  runApp(const SawitApp());
}

class SawitApp extends StatefulWidget {
  const SawitApp({super.key});

  @override
  State<SawitApp> createState() => _SawitAppState();
}

class _SawitAppState extends State<SawitApp> {
  final TfliteClassifier _classifier = TfliteClassifier();
  final RecommendationService _recommendationService = RecommendationService();
  final HistoryService _historyService = HistoryService();

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TfliteClassifier>.value(value: _classifier),
        Provider<RecommendationService>.value(value: _recommendationService),
        Provider<HistoryService>.value(value: _historyService),
      ],
      child: MaterialApp(
        title: 'SawitHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}
