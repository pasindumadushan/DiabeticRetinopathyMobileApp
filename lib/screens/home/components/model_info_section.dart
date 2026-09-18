import 'package:flutter/material.dart';

class ModelInfoSection extends StatelessWidget {
  const ModelInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About the AI Model',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              children: [
                _ModelFactRow(
                  icon: Icons.hub_outlined,
                  color: Color(0xFF2563EB),
                  title: 'EfficientNet-Lite',
                  description:
                      'The larger "teacher" network used during training to learn accurate diabetic retinopathy patterns from retinal images.',
                ),
                Divider(height: 28),
                _ModelFactRow(
                  icon: Icons.speed_rounded,
                  color: Color(0xFF7C3AED),
                  title: 'MobileNet',
                  description:
                      'The lightweight "student" network — the architecture that actually runs on your device for fast, offline predictions.',
                ),
                Divider(height: 28),
                _ModelFactRow(
                  icon: Icons.school_outlined,
                  color: Color(0xFF059669),
                  title: 'Knowledge Distillation',
                  description:
                      'The MobileNet student is trained to mimic EfficientNet-Lite\'s predictions, keeping most of its accuracy in a far smaller model.',
                ),
                Divider(height: 28),
                _ModelFactRow(
                  icon: Icons.compress_rounded,
                  color: Color(0xFFD97706),
                  title: 'Pruning',
                  description:
                      'Redundant connections inside the student network are removed, shrinking the model further with minimal accuracy loss.',
                ),
                Divider(height: 28),
                _ModelFactRow(
                  icon: Icons.memory_rounded,
                  color: Color(0xFFDC2626),
                  title: 'Quantization',
                  description:
                      'Model weights are converted to lower-precision numbers, making the final model smaller and faster to run on your phone\'s CPU.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'How to Use',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              children: [
                _StepRow(step: 1, text: 'Open the Retinal Scan tab and fill in the patient\'s details.'),
                SizedBox(height: 14),
                _StepRow(step: 2, text: 'Capture or upload up to 4 clear retinal (fundus) images.'),
                SizedBox(height: 14),
                _StepRow(step: 3, text: 'Tap Analyze to run the on-device model — no internet connection required.'),
                SizedBox(height: 14),
                _StepRow(step: 4, text: 'Review the severity grade, attention heatmap and Ben Graham-enhanced images.'),
                SizedBox(height: 14),
                _StepRow(
                  step: 5,
                  text: 'Use the result as a screening aid only — always confirm with an ophthalmologist.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelFactRow extends StatelessWidget {
  const _ModelFactRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.text});

  final int step;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF2563EB),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$step',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
