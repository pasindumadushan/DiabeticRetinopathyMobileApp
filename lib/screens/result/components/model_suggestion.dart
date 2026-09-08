import 'package:flutter/material.dart';
import '../../../models/analysis_result.dart';

class ModelSuggestion extends StatelessWidget {
  const ModelSuggestion({
    super.key,
    required this.result,
  });

  final AnalysisResult result;

  Color get suggestionBg {
    switch (result.predictedClass) {
      case 0:
        return const Color(0xFFD1FAE5);
      case 1:
        return const Color(0xFFFEF3C7);
      case 2:
        return const Color(0xFFFEE2E2);
      case 3:
        return const Color(0xFFFECACA);
      case 4:
        return const Color(0xFFFFEDD5);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color get suggestionBorder {
    switch (result.predictedClass) {
      case 0:
        return const Color(0xFF6EE7B7);
      case 1:
        return const Color(0xFFFCD34D);
      case 2:
        return const Color(0xFFFCA5A5);
      case 3:
        return const Color(0xFFF87171);
      case 4:
        return const Color(0xFFFEBB8A);
      default:
        return const Color(0xFFCBD5E1);
    }
  }

  Color get suggestionText {
    switch (result.predictedClass) {
      case 0:
        return const Color(0xFF065F46);
      case 1:
        return const Color(0xFF78350F);
      case 2:
        return const Color(0xFF7F1D1D);
      case 3:
        return const Color(0xFF7F1D1D);
      case 4:
        return const Color(0xFF7C2D12);
      default:
        return const Color(0xFF334155);
    }
  }

  Color get headerBg {
    switch (result.predictedClass) {
      case 0:
        return const Color(0xFFECFDF5);
      case 1:
        return const Color(0xFFFEFAE8);
      case 2:
        return const Color(0xFFFEF2F2);
      case 3:
        return const Color(0xFFFEF2F2);
      case 4:
        return const Color(0xFFFEF3E8);
      default:
        return const Color(0xFFF8FAFC);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommendation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Next Steps for Patient Care',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: suggestionBorder, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.severityLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: suggestionText,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  result.suggestion,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: suggestionText,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: suggestionText,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Consult an ophthalmologist for more accurate diagnosis',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: suggestionText.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
