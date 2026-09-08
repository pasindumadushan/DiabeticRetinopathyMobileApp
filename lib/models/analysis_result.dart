class AnalysisResult {
  final int predictedClass;
  final double meanPrediction;
  final List<String> imagePaths;
  final List<String> benGrahamPaths;
  final String analysisMessage;
  final String patientName;
  final int age;
  final String gender;
  final String diabetic;
  final double diabetesDuration;

  AnalysisResult({
    required this.predictedClass,
    required this.meanPrediction,
    required this.imagePaths,
    required this.benGrahamPaths,
    required this.analysisMessage,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.diabetic,
    required this.diabetesDuration,
  });

  String get severityLabel {
    switch (predictedClass) {
      case 0:
        return 'No DR';
      case 1:
        return 'Mild';
      case 2:
        return 'Moderate';
      case 3:
        return 'Severe';
      case 4:
        return 'Proliferative';
      default:
        return 'Unknown';
    }
  }

  String get suggestion {
    switch (predictedClass) {
      case 0:
        return 'No diabetic retinopathy detected. Continue regular eye check-ups.';
      case 1:
        return 'Mild DR detected. Monitor closely and consult an ophthalmologist.';
      case 2:
        return 'Moderate DR detected. Urgent ophthalmology consultation recommended.';
      case 3:
        return 'Severe DR detected. Immediate specialist consultation required.';
      case 4:
        return 'Proliferative DR detected. Urgent treatment required to prevent vision loss.';
      default:
        return 'Please consult a healthcare professional.';
    }
  }
}
