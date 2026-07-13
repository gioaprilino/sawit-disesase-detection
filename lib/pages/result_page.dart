import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/detection_result.dart';
import '../services/history_service.dart';
import '../services/recommendation_service.dart';
import '../services/tflite_classifier.dart';

class ResultPage extends StatefulWidget {
  final Uint8List imageBytes;

  const ResultPage({
    super.key,
    required this.imageBytes,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  DetectionResult? _result;
  Recommendation? _recommendation;
  bool _isProcessing = true;
  String? _error;
  bool _saved = false;

  static const Color _healthyColor = Color(0xFF2E7D32);
  static const Color _diseaseColor = Color(0xFFC62828);

  @override
  void initState() {
    super.initState();
    _classify();
  }

  Future<void> _classify() async {
    try {
      final classifier = context.read<TfliteClassifier>();
      final recommendationService = context.read<RecommendationService>();

      final result = await classifier.classifyImage(widget.imageBytes);
      final recommendation = recommendationService.get(result.className);

      if (mounted) {
        setState(() {
          _result = result;
          _recommendation = recommendation;
        });
        HapticFeedback.mediumImpact();
        _saveToHistory(result, recommendation);
      }
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('Gagal membaca gambar')) {
      return 'Gambar tidak terbaca. Pastikan foto daun terlihat jelas dan coba ulang.';
    }
    if (msg.contains('Model belum dimuat')) {
      return 'Model belum siap. Silakan kembali dan coba lagi.';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  Future<void> _saveToHistory(DetectionResult result, Recommendation? rec) async {
    try {
      final historyService = context.read<HistoryService>();
      await historyService.saveNew(
        imageBytes: widget.imageBytes,
        label: result.className,
        confidence: result.confidence,
        probabilities: result.probabilities,
        diseaseName: rec?.name,
        severity: rec?.severity,
      );
      if (mounted) setState(() => _saved = true);
    } catch (_) {}
  }

  Future<void> _shareResult() async {
    final result = _result!;
    final rec = _recommendation;
    final isHealthy = result.className == 'normal';

    final buffer = StringBuffer();
    buffer.writeln('*Hasil Deteksi SawitHub*');
    buffer.writeln('');
    buffer.writeln('Status: ${rec?.name ?? result.className}');
    buffer.writeln('Kepercayaan: ${(result.confidence * 100).toStringAsFixed(1)}%');
    buffer.writeln('');

    if (rec != null && !isHealthy) {
      buffer.writeln('*Rekomendasi Penanganan:*');
      if (rec.treatments.isNotEmpty) {
        buffer.writeln(rec.treatments.first);
        buffer.writeln('');
      }
      buffer.writeln('*Pencegahan:*');
      if (rec.preventions.isNotEmpty) {
        buffer.writeln(rec.preventions.first);
      }
      buffer.writeln('');
      buffer.writeln('Konsultasikan dengan penyuluh pertanian untuk penanganan lebih lanjut.');
    }

    buffer.writeln('');
    buffer.writeln('Dikirim dari SawitHub');

    await Share.share(buffer.toString(), subject: 'Hasil Deteksi SawitHub');
  }

  Color _getStatusColor(String className) {
    return className == 'normal' ? _healthyColor : _diseaseColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Deteksi'),
        centerTitle: true,
        actions: [
          if (_result != null)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Bagikan',
              onPressed: _shareResult,
            ),
        ],
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Menganalisis gambar...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mohon tunggu sebentar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red[400]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Kembali'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildResult(),
    );
  }

  Widget _buildResult() {
    final result = _result!;
    final statusColor = _getStatusColor(result.className);
    final rec = _recommendation;
    final labels = context.read<TfliteClassifier>().labels;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              widget.imageBytes,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          if (_saved)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 14, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Tersimpan ke riwayat',
                    style: TextStyle(fontSize: 12, color: Colors.green[600]),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          _buildDetectionCard(result, statusColor),
          const SizedBox(height: 24),
          _buildProbabilitySection(result, statusColor, labels),
          if (rec != null) ...[
            const SizedBox(height: 24),
            _buildRecommendationSection(rec),
          ],
        ],
      ),
    );
  }

  Widget _buildDetectionCard(DetectionResult result, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            result.className == 'normal'
                ? Icons.check_circle
                : Icons.warning_amber_rounded,
            size: 48,
            color: statusColor,
          ),
          const SizedBox(height: 12),
          Text(
            _recommendation?.name ?? result.className,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tingkat Kepercayaan: ${(result.confidence * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (_recommendation != null) ...[
            const SizedBox(height: 12),
            Text(
              _recommendation!.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProbabilitySection(
    DetectionResult result,
    Color statusColor,
    List<String> labels,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Probabilitas per Kelas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...result.probabilities.asMap().entries.map((entry) {
          final label = entry.key < labels.length
              ? labels[entry.key]
              : 'Kelas ${entry.key}';
          final proba = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(label)),
                    Text('${(proba * 100).toStringAsFixed(1)}%'),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: proba,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      label == result.className
                          ? statusColor
                          : Colors.grey[400]!,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecommendationSection(Recommendation rec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.medical_services, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Rekomendasi Penanganan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (rec.treatments.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medication, size: 20, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Tindakan Penanganan',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...rec.treatments.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key + 1}. ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Expanded(
                          child: Text(entry.value),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
        if (rec.preventions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield, size: 20, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Tindakan Pencegahan',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...rec.preventions.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(entry.value),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
        if (rec.severity != 'tidak_ada') ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rekomendasi ini bersifat umum. Konsultasikan dengan ahli pertanian untuk penanganan yang lebih tepat.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange[800],
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
