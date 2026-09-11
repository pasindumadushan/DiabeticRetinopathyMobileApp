import 'dart:io';

import 'package:flutter/material.dart';

import '../../../models/analysis_result.dart';
import '../../result/result.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({
    super.key,
    required this.records,
  });

  final List<Map<String, dynamic>> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text(
          'No saved records yet',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: records.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final record = records[index];
        final name = record['patient_name'] ?? 'N/A';
        final age = record['age'] ?? '-';
        final gender = record['gender'] ?? 'N/A';
        final diabetic = record['diabetic'] ?? 'No';
        final severity = record['severity'] ?? 'Not analyzed';

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _openRecordResult(context, record),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF2563EB),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Age', value: '$age'),
                  const SizedBox(height: 10),
                  _InfoRow(label: 'Gender', value: gender),
                  const SizedBox(height: 10),
                  _InfoRow(label: 'Diabetic', value: diabetic),
                  const SizedBox(height: 10),
                  _InfoRow(label: 'Severity', value: severity),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openRecordResult(
    BuildContext context,
    Map<String, dynamic> record,
  ) async {
    final imagePathsRaw = record['image_paths'] as String? ?? '';
    final imagePaths = imagePathsRaw
        .split(',')
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toList();

    // Ben Graham enhanced images were saved alongside the original uploads,
    // in the same patient_record_<id> folder, during analysis.
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

    final result = AnalysisResult(
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

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultScreen(result: result),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
