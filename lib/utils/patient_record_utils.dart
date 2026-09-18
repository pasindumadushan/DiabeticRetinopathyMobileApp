import 'dart:io';

import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../screens/result/result.dart';

/// Returns the first saved image path for a `patient_records` row, or null
/// if the record has no saved images.
String? firstImagePath(Map<String, dynamic> record) {
  final raw = record['image_paths'] as String? ?? '';
  final paths = raw.split(',').map((path) => path.trim()).where((path) => path.isNotEmpty);
  return paths.isEmpty ? null : paths.first;
}

/// Rebuilds an [AnalysisResult] from a saved `patient_records` row without
/// re-running the model: the original/Ben Graham images are read back from
/// the patient's saved folder on disk, and the severity comes straight from
/// the `severity` column in SQLite.
Future<AnalysisResult> analysisResultFromRecord(Map<String, dynamic> record) async {
  final imagePathsRaw = record['image_paths'] as String? ?? '';
  final imagePaths = imagePathsRaw
      .split(',')
      .map((path) => path.trim())
      .where((path) => path.isNotEmpty)
      .toList();

  // Ben Graham enhanced images were saved alongside the original uploads, in
  // the same patient_record_<id> folder, during analysis.
  final benGrahamPaths = <String>[];
  if (imagePaths.isNotEmpty) {
    final folder = File(imagePaths.first).parent;
    if (await folder.exists()) {
      benGrahamPaths.addAll(
        folder
            .listSync()
            .whereType<File>()
            .where((file) => file.path.contains('ben_graham'))
            .map((file) => file.path),
      );
    }
  }

  final severityLabel = record['severity'] as String?;

  return AnalysisResult(
    predictedClass: AnalysisResult.classFromSeverityLabel(severityLabel),
    meanPrediction: 0.0,
    imagePaths: imagePaths,
    benGrahamPaths: benGrahamPaths,
    analysisMessage: '',
    patientName: record['patient_name'] as String? ?? 'N/A',
    age: record['age'] as int? ?? 0,
    gender: record['gender'] as String? ?? 'N/A',
    diabetic: record['diabetic'] as String? ?? 'No',
    diabetesDuration: (record['diabetes_duration'] as num?)?.toDouble() ?? 0.0,
  );
}

/// Opens [ResultScreen] for a saved patient record — used when a record is
/// tapped from the history list or the home screen's recent-scans carousel.
Future<void> openRecordResult(BuildContext context, Map<String, dynamic> record) async {
  final result = await analysisResultFromRecord(record);
  if (!context.mounted) return;

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ResultScreen(result: result),
    ),
  );
}
