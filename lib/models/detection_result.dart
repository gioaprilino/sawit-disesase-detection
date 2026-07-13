class DetectionResult {
  final String className;
  final double confidence;
  final List<double> probabilities;

  DetectionResult({
    required this.className,
    required this.confidence,
    required this.probabilities,
  });

  factory DetectionResult.fromOutput(
    List<double> output,
    List<String> labels,
  ) {
    final maxIndex = output.indexOf(output.reduce((a, b) => a > b ? a : b));
    return DetectionResult(
      className: labels[maxIndex],
      confidence: output[maxIndex],
      probabilities: output,
    );
  }
}
