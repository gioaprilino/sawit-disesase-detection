<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.44+-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.12+-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/TFLite-0.12.1-orange?logo=tensorflow" alt="TFLite">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
</p>

<h1 align="center">🌴 SawitHub</h1>
<h3 align="center">Deteksi Penyakit Daun Kelapa Sawit</h3>

<p align="center">
  Aplikasi mobile berbasis <strong>TensorFlow Lite</strong> untuk mendeteksi penyakit
  daun kelapa sawit secara <em>on-device</em> &mdash; <strong>100% offline</strong>,
  tanpa perlu koneksi internet.
</p>

---

## Daftar Isi

- [Tentang](#tentang)
- [Fitur](#fitur)
- [Model Machine Learning](#model-machine-learning)
- [Tech Stack](#tech-stack)
- [Persyaratan Sistem](#persyaratan-sistem)
- [Cara Menjalankan](#cara-menjalankan)
- [Struktur Proyek](#struktur-proyek)
- [Cara Menggunakan](#cara-menggunakan)
- [Kontributor](#kontributor)
- [Lisensi](#lisensi)

---

## Tentang

Indonesia adalah produsen minyak kelapa sawit terbesar di dunia. Namun, petani sawit sering menghadapi masalah keterlambatan deteksi hama dan penyakit yang dapat menyebar ke pohon lain, menurunkan hasil panen, dan merugikan petani.

**SawitHub** hadir untuk membantu petani mendeteksi penyakit daun kelapa sawit sejak dini hanya dengan memotret daun menggunakan ponsel. Cukup ambil foto, aplikasi akan mengklasifikasikan kondisi daun dan memberikan rekomendasi penanganan serta pencegahan dalam Bahasa Indonesia.

---

## Fitur

| Fitur | Keterangan |
|-------|------------|
| 📷 **Ambil Foto** | Deteksi dari kamera langsung |
| 🖼️ **Pilih dari Galeri** | Deteksi dari foto yang sudah ada |
| 🔬 **Klasifikasi Otomatis** | 6 kelas kondisi daun sawit menggunakan CNN |
| 📋 **Rekomendasi** | Saran penanganan & pencegahan per penyakit |
| 📜 **Riwayat Deteksi** | Semua hasil tersimpan lokal (tanpa internet) |
| 📤 **Bagikan** | Bagikan hasil deteksi ke aplikasi lain |
| 📱 **UI Ramah Petani** | Tombol besar, teks jelas, sederhana |

### Kelas Deteksi

| Label | Penyakit | Tingkat Keparahan |
|-------|----------|:---:|
| `capnodium` | Jamur Jelaga (Capnodium) | Sedang |
| `cochliobolus` | Bercak Daun (Cochliobolus) | Tinggi |
| `culvularia` | Hawar Daun (Curvularia) | Tinggi |
| `drecshlera` | Bercak Daun Drechslera | Tinggi |
| `hara` | Kekurangan Unsur Hara | Sedang |
| `normal` | Sehat | Tidak Ada |

---

## Model Machine Learning

Model yang digunakan berasal dari repositori:
<p align="center">
  <a href="https://github.com/sawitHub/sawitHub-machine-learning">
    <code>github.com/sawitHub/sawitHub-machine-learning</code>
  </a>
</p>

**Detail Model:**
- **Arsitektur:** MobileNet (Transfer Learning) + Custom Layers
- **Input:** 224×224 pixel, RGB
- **Format:** TensorFlow Lite (`.tflite`)
- **Inference:** Sepenuhnya *on-device* via `tflite_flutter`
- **Evaluasi:** Akurasi 97%, F1-Score 0.97 (Model 2)

> Model dilatih menggunakan dataset dari penelitian <em>"Machine Learning for Detection of Palm Oil Leaf Disease Visually using Convolutional Neural Network Algorithm"</em> dan dataset Kaggle. Detail lengkap dapat dilihat di repositori machine learning di atas.

---

## Tech Stack

| Komponen | Teknologi |
|----------|-----------|
| **Framework** | Flutter 3.44+ |
| **Bahasa** | Dart 3.12+ |
| **ML Inference** | [`tflite_flutter`](https://pub.dev/packages/tflite_flutter) ^0.12.1 |
| **State Management** | [`provider`](https://pub.dev/packages/provider) ^6.1.2 |
| **Penyimpanan Lokal** | [`hive`](https://pub.dev/packages/hive) ^2.2.3 + [`hive_flutter`](https://pub.dev/packages/hive_flutter) ^1.1.0 |
| **Image Picker** | [`image_picker`](https://pub.dev/packages/image_picker) ^1.1.2 |
| **Image Processing** | [`image`](https://pub.dev/packages/image) ^4.5.3 |
| **Share** | [`share_plus`](https://pub.dev/packages/share_plus) ^10.1.4 |
| **Path Provider** | [`path_provider`](https://pub.dev/packages/path_provider) ^2.1.5 |

---

## Persyaratan Sistem

- **Flutter SDK** 3.44+ & Dart 3.12+
- **Java JDK** 17 atau 21 (Java 25+ **tidak** kompatibel)
- **Android Studio** / VS Code dengan ekstensi Flutter
- **Perangkat Android** (fisik atau emulator)

---

## Cara Menjalankan

```bash
# Clone repositori
git clone https://github.com/username/sawit_app.git
cd sawit_app

# Install dependencies
flutter pub get

# Jalankan di perangkat / emulator
flutter run
```

> **Catatan:** Pastikan `JAVA_HOME` mengarah ke JDK 17/21, bukan 25+.
> ```bash
> export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
> ```

Jika ingin mode rilis:
```bash
flutter run --release
```

---

## Struktur Proyek

```
sawit_app/
├── assets/
│   ├── model.tflite              ← Model TensorFlow Lite
│   ├── labels.txt                ← Label kelas deteksi
│   └── recommendations.json      ← Data rekomendasi penyakit
├── lib/
│   ├── main.dart                 ← Entry point & Provider setup
│   ├── models/
│   │   ├── detection_record.dart ← Model riwayat deteksi (Hive)
│   │   └── detection_result.dart ← Model hasil klasifikasi
│   ├── pages/
│   │   ├── home_page.dart        ← Halaman utama (menu besar)
│   │   ├── result_page.dart      ← Halaman hasil deteksi
│   │   ├── history_page.dart     ← Riwayat deteksi
│   │   ├── history_detail_page.dart ← Detail riwayat
│   │   └── about_page.dart       ← Tentang aplikasi
│   └── services/
│       ├── tflite_classifier.dart    ← Wrapper inferensi TFLite
│       ├── history_service.dart      ← CRUD riwayat (Hive)
│       └── recommendation_service.dart ← Load rekomendasi
├── android/                      ← Konfigurasi Android
├── ios/                          ← Konfigurasi iOS
├── test/                         ← Pengujian
└── pubspec.yaml                  ← Manifest proyek
```

---

## Cara Menggunakan

1. **Buka aplikasi** SawitHub
2. **Pilih menu:**
   - **Ambil Foto** &mdash; arahkan kamera ke daun sawit
   - **Pilih dari Galeri** &mdash; pilih foto yang sudah ada
3. **Tunggu** proses analisis (~detik)
4. **Lihat hasil:**
   - Nama penyakit / kondisi
   - Tingkat keyakinan (probabilitas)
   - Deskripsi penyakit
   - Rekomendasi penanganan
   - Rekomendasi pencegahan
5. **Simpan otomatis** ke riwayat
6. **Lihat riwayat** kapan saja lewat menu **Riwayat Deteksi**

---

## Kontributor

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/qiqin">
        <sub><b>Muthaqin Dean</b></sub>
      </a>
      <br><sub>Machine Learning</sub>
    </td>
    <td align="center">
      <a href="https://github.com/yusrianasghany">
        <sub><b>Yusrian Asghany</b></sub>
      </a>
      <br><sub>Machine Learning</sub>
    </td>
    <td align="center">
      <a href="https://github.com/gioaprilino">
        <sub><b>Gio Aprilino</b></sub>
      </a>
      <br><sub>Mobile Developer</sub>
    </td>
  </tr>
</table>

---

## Lisensi

Proyek ini dilisensikan di bawah **MIT License** &mdash; lihat file [LICENSE](LICENSE) untuk detail.
