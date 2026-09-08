import 'package:flutter/material.dart';
import '../../../models/analysis_result.dart';

class ResultHeader extends StatelessWidget {
  const ResultHeader({
    super.key,
    required this.result,
  });

  final AnalysisResult result;

  Color get headerGradientStart {
    switch (result.predictedClass) {
      case 0:
        return const Color(0xFF059669);
      case 1:
        return const Color(0xFFD97706);
      case 2:
        return const Color(0xFFDC2626);
      case 3:
        return const Color(0xFFBE123C);
      case 4:
        return const Color(0xFF7C2D12);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color get headerGradientEnd {
    switch (result.predictedClass) {
      case 0:
        return const Color(0xFF10B981);
      case 1:
        return const Color(0xFFF59E0B);
      case 2:
        return const Color(0xFFEF4444);
      case 3:
        return const Color(0xFFE11D48);
      case 4:
        return const Color(0xFFA16207);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color get shadowColor {
    switch (result.predictedClass) {
      case 0:
        return const Color(0xFF10B981);
      case 1:
        return const Color(0xFFF59E0B);
      case 2:
        return const Color(0xFFEF4444);
      case 3:
        return const Color(0xFFE11D48);
      case 4:
        return const Color(0xFFA16207);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  IconData get severityIcon {
    switch (result.predictedClass) {
      case 0:
        return Icons.check_circle_rounded;
      case 1:
        return Icons.warning_rounded;
      case 2:
        return Icons.error_rounded;
      case 3:
        return Icons.error_rounded;
      case 4:
        return Icons.priority_high_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            headerGradientStart,
            headerGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  severityIcon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RetinaInsight',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Analysis Complete',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Diabetic Retinopathy Severity: ${result.severityLabel}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(icon: Icons.analytics, label: 'Class ${result.predictedClass}'),
              _InfoChip(icon: Icons.show_chart, label: 'Mean: ${result.meanPrediction.toStringAsFixed(2)}'),
              _InfoChip(icon: Icons.verified_user, label: 'AI Predicted'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
