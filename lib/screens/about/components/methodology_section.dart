import 'package:flutter/material.dart';

class MethodologySection extends StatelessWidget {
  const MethodologySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Research & Optimization Approach',
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
                _MethodChip(
                  icon: Icons.psychology_alt_outlined,
                  color: Color(0xFF2563EB),
                  title: 'Deductive Approach',
                  description: 'Hypotheses on model efficiency are formed from existing theory, then tested against benchmark results.',
                ),
                Divider(height: 28),
                _MethodChip(
                  icon: Icons.design_services_outlined,
                  color: Color(0xFF7C3AED),
                  title: 'Design-Oriented Methodology',
                  description: 'The app itself is the research artifact — built, evaluated, and iterated on to solve a real diagnostic problem.',
                ),
                Divider(height: 28),
                _MethodChip(
                  icon: Icons.bar_chart_rounded,
                  color: Color(0xFF059669),
                  title: 'Quantitative Research Design',
                  description: 'Model accuracy, size, and latency are measured numerically and compared across optimization stages.',
                ),
                Divider(height: 32, thickness: 1),
                _MethodChip(
                  icon: Icons.memory_rounded,
                  color: Color(0xFFDC2626),
                  title: 'Quantization',
                  description: 'Reduces weight precision so the model runs smaller and faster on-device.',
                ),
                Divider(height: 28),
                _MethodChip(
                  icon: Icons.tune_rounded,
                  color: Color(0xFFD97706),
                  title: 'Fine-Tuning',
                  description: 'Adapts pre-trained CNN backbones to the retinal fundus dataset for better DR-specific accuracy.',
                ),
                Divider(height: 28),
                _MethodChip(
                  icon: Icons.compress_rounded,
                  color: Color(0xFFEA580C),
                  title: 'Pruning',
                  description: 'Removes redundant weights and connections to shrink the model with minimal accuracy loss.',
                ),
                Divider(height: 28),
                _MethodChip(
                  icon: Icons.school_outlined,
                  color: Color(0xFF0891B2),
                  title: 'Knowledge Distillation',
                  description: 'Trains a compact "student" model to replicate a larger "teacher" model\'s predictions.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
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
