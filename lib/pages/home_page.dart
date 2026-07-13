import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/recommendation_service.dart';
import '../services/tflite_classifier.dart';
import 'about_page.dart';
import 'history_page.dart';
import 'result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    final classifier = context.read<TfliteClassifier>();
    final recommendationService = context.read<RecommendationService>();
    if (classifier.isLoaded) return;
    try {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
      await Future.wait([
        classifier.loadModel(),
        recommendationService.load(),
      ]);
    } catch (e) {
      _loadError = 'Gagal memuat: $e';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile == null) return;

    final Uint8List imageBytes = await pickedFile.readAsBytes();

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(imageBytes: imageBytes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SawitHub'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            Icon(
              Icons.forest,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Deteksi Penyakit Daun Kelapa Sawit',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ambil foto daun kelapa sawit untuk mendeteksi kondisi kesehatannya.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat model dan data rekomendasi...'),
                ],
              )
            else if (_loadError != null)
              Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 12),
                  Text(
                    _loadError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[400]),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _initServices,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildMenuCard(
                    icon: Icons.camera_alt,
                    iconColor: Colors.white,
                    iconBgColor: theme.colorScheme.primary,
                    title: 'Ambil Foto',
                    subtitle: 'Ambil foto daun kelapa sawit menggunakan kamera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    icon: Icons.photo_library,
                    iconColor: Colors.white,
                    iconBgColor: Colors.orange,
                    title: 'Pilih dari Galeri',
                    subtitle: 'Pilih foto daun kelapa sawit dari galeri',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    icon: Icons.history,
                    iconColor: Colors.white,
                    iconBgColor: Colors.blue,
                    title: 'Riwayat Deteksi',
                    subtitle: 'Lihat hasil deteksi penyakit sebelumnya',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryPage()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    icon: Icons.info_outline,
                    iconColor: Colors.white,
                    iconBgColor: Colors.grey,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Informasi tentang aplikasi SawitHub',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: iconBgColor,
                radius: 24,
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
