import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang SawitHub'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.forest,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'SawitHub',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Deteksi Penyakit Daun Kelapa Sawit',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Versi 1.0.0',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              theme,
              Icons.info_outline,
              'Cara Penggunaan',
              [
                '1. Buka aplikasi dan tekan tombol "Ambil Foto" atau "Pilih dari Galeri"',
                '2. Arahkan kamera ke daun kelapa sawit yang ingin diperiksa',
                '3. Tunggu proses analisis selesai (beberapa detik)',
                '4. Lihat hasil deteksi beserta rekomendasi penanganan',
                '5. Hasil deteksi akan tersimpan otomatis di riwayat',
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              theme,
              Icons.warning_amber_rounded,
              'Peringatan',
              [
                'Aplikasi ini hanya alat bantu deteksi awal dan tidak menggantikan diagnosis ahli pertanian. Selalu konsultasikan dengan penyuluh pertanian atau ahli agronomi untuk penanganan yang tepat.',
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              theme,
              Icons.science_outlined,
              'Tentang Model',
              [
                'SawitHub menggunakan model kecerdasan buatan (AI) yang dilatih untuk mengenali 5 jenis penyakit daun kelapa sawit dan 1 kondisi sehat. Model berjalan sepenuhnya di perangkat Anda tanpa perlu koneksi internet.',
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              theme,
              Icons.shield_outlined,
              'Privasi',
              [
                'Semua data dan gambar diproses sepenuhnya di perangkat Anda. Tidak ada data yang dikirim ke server eksternal. Privasi data Anda terjamin.',
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'Dikembangkan untuk Petani Kelapa Sawit Indonesia',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, IconData icon, String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              item,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          )),
        ],
      ),
    );
  }
}
