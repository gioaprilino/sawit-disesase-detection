import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/detection_result.dart';

class TfliteClassifier {
  static const String _modelPath = 'assets/model.tflite';
  static const String _labelsPath = 'assets/labels.txt';
  static const int _inputSize = 224;

  Interpreter? _interpreter;
  List<String> _labels = [];
  List<int>? _outputShape;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<String> get labels => List.unmodifiable(_labels);

  Future<void> loadModel() async {
    final options = InterpreterOptions()..threads = 4;
    _interpreter = await Interpreter.fromAsset(_modelPath, options: options);

    final outputTensor = _interpreter!.getOutputTensors().first;
    _outputShape = outputTensor.shape;

    final labelsData = await rootBundle.loadString(_labelsPath);
    _labels = LineSplitter.split(labelsData)
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    _isLoaded = true;
  }

  Future<DetectionResult> classifyImage(Uint8List imageBytes) async {
    if (!_isLoaded || _interpreter == null) {
      throw StateError('Model belum dimuat. Panggil loadModel() terlebih dahulu.');
    }

    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw FormatException('Gagal membaca gambar.');
    }

    img.Image resized = img.copyResize(image, width: _inputSize, height: _inputSize);

    final input = _preprocessImage(resized);

    final outputShape = _outputShape!;
    final output = List.generate(
      outputShape[0],
      (_) => List<double>.filled(outputShape[1], 0.0),
    );

    _interpreter!.run(input, output);

    List<double> probabilities = output.first;
    return DetectionResult.fromOutput(probabilities, _labels);
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    final imageMatrix = List.generate(
      _inputSize,
      (y) => List.generate(
        _inputSize,
        (x) {
          final pixel = image.getPixel(x, y);
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        },
      ),
    );
    return [imageMatrix];
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}
